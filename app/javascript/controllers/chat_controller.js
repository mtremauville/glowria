import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "messages", "submit", "typing",
    "cameraBtn", "cameraView", "video", "canvas",
    "photoPreview", "photoImg",
    "conversationId"
  ]

  static values = { avatarUrl: String }

  connect() {
    this.stream             = null
    this.capturedBlob       = null
    this.capturedUrl        = null
    this._pendingConvId     = null  // set during stream, applied after
    this.scrollToBottom()
  }

  disconnect() {
    this.stopStream()
  }

  // ── Envoi message ────────────────────────────────────────
  async send(event) {
    event.preventDefault()

    const message  = event.currentTarget.dataset.message || this.inputTarget.value.trim()
    const hasPhoto = !!this.capturedBlob
    const hasText  = !!message

    if (!hasText && !hasPhoto) return

    // Remove welcome state if present
    const welcome = this.messagesTarget.querySelector(".chat-welcome")
    if (welcome) welcome.remove()

    this.appendUserMessage(message, this.capturedUrl)

    this.inputTarget.value = ""
    const blob = this.capturedBlob
    this.clearPhoto()
    this.setLoading(true)

    const assistantBubble = this.createAssistantBubble()

    try {
      await this.streamResponse(message, blob, assistantBubble)
    } catch (err) {
      console.error("Chat error:", err)
      assistantBubble.textContent = "Erreur de connexion. Réessaie."
    } finally {
      this.setLoading(false)
      this.scrollToBottom()
      // Update URL and sidebar after the stream is fully done
      if (this._pendingConvId) {
        this._applyConversationId(this._pendingConvId)
        this._pendingConvId = null
      }
    }
  }

  async streamResponse(message, blob, bubble) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const formData  = new FormData()

    if (message) formData.append("message", message)
    if (blob)    formData.append("image", blob, "photo.jpg")

    // Include conversation_id if we have one (use hasXTarget to avoid MissingTargetError)
    if (this.hasConversationIdTarget && this.conversationIdTarget.value) {
      formData.append("conversation_id", this.conversationIdTarget.value)
    }

    const response = await fetch("/chat_messages", {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "text/event-stream"
      },
      body: formData
    })

    if (!response.ok) throw new Error(`HTTP ${response.status}`)

    const reader  = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer    = ""
    let eventType = ""

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split("\n")
      buffer = lines.pop()

      for (const line of lines) {
        if (line.startsWith("event:")) {
          eventType = line.slice(6).trim()
          continue
        }

        if (!line.startsWith("data:")) continue

        const raw = line.slice(5).trim()
        if (!raw) continue

        let parsed
        try { parsed = JSON.parse(raw) } catch { continue }

        if (eventType === "init") {
          if (parsed.conversation_id) {
            // Store for later — will apply after stream finishes
            this._pendingConvId = parsed.conversation_id
            // Also update the hidden input now so subsequent calls use it
            if (this.hasConversationIdTarget) {
              this.conversationIdTarget.value = parsed.conversation_id
            }
          }
        } else if (eventType === "token" || parsed.token) {
          if (parsed.token) {
            if (!bubble.dataset.started) {
              bubble.innerHTML = ""   // retire les points d'animation
              bubble.dataset.started = "1"
            }
            bubble.textContent += parsed.token
            this.scrollToBottom()
          }
        } else if (eventType === "done") {
          bubble.innerHTML = this.renderMarkdown(bubble.textContent)
        } else if (eventType === "error") {
          bubble.innerHTML = parsed.error || "Une erreur est survenue. Réessaie."
        }

        eventType = ""
      }
    }

    // Ensure markdown is rendered if done event was missed
    if (bubble.dataset.started && !bubble.innerHTML.includes("<")) {
      bubble.innerHTML = this.renderMarkdown(bubble.textContent)
    } else if (!bubble.dataset.started) {
      // Stream closed without any token (API key manquante, timeout, etc.)
      bubble.innerHTML = "Erreur de connexion. Réessaie dans un instant."
    }
  }

  // Called AFTER the stream finishes — safe to update URL then
  _applyConversationId(conversationId) {
    const newUrl = `/conversations/${conversationId}`

    // Update browser URL without triggering navigation
    if (!window.location.pathname.startsWith(`/conversations/${conversationId}`)) {
      history.replaceState({ conversationId }, "", newUrl)
    }

    // Highlight active conversation in sidebar
    document.querySelectorAll(".chat-history__item").forEach(el => {
      el.classList.remove("chat-history__item--active")
    })
    const convLink = document.querySelector(`.chat-history__link[href="${newUrl}"]`)
    if (convLink) {
      convLink.closest(".chat-history__item")?.classList.add("chat-history__item--active")
    }
  }

  // ── Caméra getUserMedia ──────────────────────────────────
  async openCamera() {
    if (this.stream) { this.closeCamera(); return }
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment", width: { ideal: 1280 } }
      })
      this.videoTarget.srcObject = this.stream
      await this.videoTarget.play()
      this.cameraViewTarget.hidden = false
      this.cameraBtnTarget.classList.add("chat-camera-btn--active")
    } catch (err) {
      alert("Impossible d'accéder à la caméra. Vérifie les permissions.")
    }
  }

  closeCamera() {
    this.stopStream()
    this.cameraViewTarget.hidden = true
    this.cameraBtnTarget.classList.remove("chat-camera-btn--active")
  }

  capturePhoto() {
    const video  = this.videoTarget
    const canvas = this.canvasTarget
    canvas.width  = video.videoWidth
    canvas.height = video.videoHeight
    canvas.getContext("2d").drawImage(video, 0, 0)
    this.closeCamera()
    canvas.toBlob(blob => {
      this.capturedBlob = blob
      this.capturedUrl  = URL.createObjectURL(blob)
      this.photoImgTarget.src = this.capturedUrl
      this.photoPreviewTarget.hidden = false
      this.inputTarget.placeholder = "Ajoute un commentaire… (facultatif)"
      this.inputTarget.focus()
    }, "image/jpeg", 0.92)
  }

  stopStream() {
    if (this.stream) {
      this.stream.getTracks().forEach(t => t.stop())
      this.stream = null
    }
  }

  removePhoto() { this.clearPhoto() }

  clearPhoto() {
    if (this.capturedUrl) URL.revokeObjectURL(this.capturedUrl)
    this.capturedBlob = null
    this.capturedUrl  = null
    this.photoPreviewTarget.hidden = true
    this.photoImgTarget.src = ""
    this.inputTarget.placeholder = "Pose ta question skincare…"
  }

  // ── Bulles ───────────────────────────────────────────────
  appendUserMessage(text, photoUrl) {
    const imgHtml    = photoUrl ? `<img src="${photoUrl}" class="chat-message__photo" alt="Photo">` : ""
    const textHtml   = text ? `<span>${text}</span>` : ""
    const avatarHtml = this.avatarUrlValue
      ? `<img src="${this.avatarUrlValue}" class="chat-avatar-img" alt="">`
      : `<i class="fa-solid fa-user"></i>`

    const wrapper = document.createElement("div")
    wrapper.className = "chat-message chat-message--user"
    wrapper.innerHTML = `
      <div class="chat-message__avatar">${avatarHtml}</div>
      <div class="chat-message__bubble">${imgHtml}${textHtml}</div>
    `
    this.messagesTarget.appendChild(wrapper)
    this.scrollToBottom()
  }

  createAssistantBubble() {
    const wrapper = document.createElement("div")
    wrapper.className = "chat-message chat-message--assistant"
    wrapper.innerHTML = `
      <div class="chat-message__avatar"><i class="fa-solid fa-wand-magic-sparkles"></i></div>
      <div class="chat-message__bubble">
        <div class="chat-bubble-typing">
          <span></span><span></span><span></span>
        </div>
      </div>
    `
    this.messagesTarget.appendChild(wrapper)
    this.scrollToBottom()
    return wrapper.querySelector(".chat-message__bubble")
  }

  // ── Utilitaires ──────────────────────────────────────────
  renderMarkdown(text) {
    return text
      .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
      .replace(/\*(.*?)\*/g, "<em>$1</em>")
      .replace(/^- (.+)/gm, "<li>$1</li>")
      .replace(/(<li>.*<\/li>)/s, "<ul>$1</ul>")
      .replace(/\n/g, "<br>")
  }

  setLoading(loading) {
    this.submitTarget.disabled = loading
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.send(event)
    }
  }
}
