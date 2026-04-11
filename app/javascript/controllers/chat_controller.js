import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages", "submit", "typing"]

  connect() {
    this.scrollToBottom()
  }

  async send(event) {
    event.preventDefault()

    // Support les boutons de suggestion (data-message) et le formulaire de saisie
    const message = event.currentTarget.dataset.message || this.inputTarget.value.trim()
    if (!message) return

    // Afficher le message utilisateur immédiatement
    this.appendMessage("user", message)
    this.inputTarget.value = ""
    this.setLoading(true)

    // Créer la bulle de réponse vide (sera remplie par le stream)
    const assistantBubble = this.createAssistantBubble()

    try {
      await this.streamResponse(message, assistantBubble)
    } catch (err) {
      assistantBubble.textContent = "❌ Erreur de connexion. Réessaie."
    } finally {
      this.setLoading(false)
      this.scrollToBottom()
    }
  }

  async streamResponse(message, bubble) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    const response = await fetch("/chat_messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/event-stream"
      },
      body: new URLSearchParams({ message })
    })

    if (!response.ok) throw new Error(`HTTP ${response.status}`)

    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ""

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split("\n")
      buffer = lines.pop() // garder le dernier fragment incomplet

      for (const line of lines) {
        if (line.startsWith("data:")) {
          const raw = line.slice(5).trim()
          try {
            const parsed = JSON.parse(raw)
            if (parsed.token) {
              bubble.textContent += parsed.token
              this.scrollToBottom()
            }
          } catch { /* ligne incomplète, on ignore */ }
        }
        if (line.includes("event: done")) {
          // Ajouter le rendu Markdown après réception complète
          bubble.innerHTML = this.renderMarkdown(bubble.textContent)
        }
      }
    }
  }

  appendMessage(role, content) {
    const wrapper = document.createElement("div")
    wrapper.className = `chat-message chat-message--${role}`
    wrapper.innerHTML = `
      <div class="chat-message__avatar">${role === "user" ? "👤" : "✨"}</div>
      <div class="chat-message__bubble">${content}</div>
    `
    this.messagesTarget.appendChild(wrapper)
    this.scrollToBottom()
  }

  createAssistantBubble() {
    const wrapper = document.createElement("div")
    wrapper.className = "chat-message chat-message--assistant"
    wrapper.innerHTML = `
      <div class="chat-message__avatar">✨</div>
      <div class="chat-message__bubble chat-message__bubble--streaming"></div>
    `
    this.messagesTarget.appendChild(wrapper)
    this.scrollToBottom()
    return wrapper.querySelector(".chat-message__bubble")
  }

  // Rendu Markdown basique (gras, italique, listes, sauts de ligne)
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
    this.typingTarget.hidden   = !loading
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  // Envoyer avec Entrée (Shift+Entrée = saut de ligne)
  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.send(event)
    }
  }
}
