# 🌟 Glowria - AI-Powered Skincare Assistant

> **Intelligent ingredient conflict detection & personalized skincare routines powered by AI**

**[🌐 Live Demo](https://glowria-13e2b2a157f6.herokuapp.com)** | **[📸 Screenshots](#screenshots)**
<img src="https://github.com/mtremauville/glowria/blob/main/2.png" width= "25%">
<img src="https://github.com/mtremauville/glowria/blob/main/3.png" width= "25%">
<img src="https://github.com/mtremauville/glowria/blob/main/4.png" width= "25%">
<img src="https://github.com/mtremauville/glowria/blob/main/5.png" width= "25%">

---

## 🎯 What is Glowria?

Glowria is a full-stack SaaS application that helps users understand their skincare ingredients and build personalized routines. Using AI, it analyzes ingredient interactions, identifies potential conflicts, and recommends tailored skincare regimens.

**The Problem:** Most people don't understand what's in their skincare products or how ingredients interact.

**The Solution:** AI-powered analysis + personalized recommendations = educated skincare choices.

---

## ✨ Features

- 🤖 **AI-Powered Analysis** - Claude API integration for intelligent ingredient analysis
- 🚨 **Conflict Detection** - Identifies potentially problematic ingredient combinations
- 💡 **Personalized Routines** - Generates custom AM/PM skincare recommendations
- 🧴 **Ingredient Database** - Comprehensive database of skincare actives and their properties
- 👤 **User Accounts** - Secure authentication with Devise + JWT
- 📱 **Mobile-Friendly** - Responsive design for all devices
- 🌙 **Production-Ready** - Deployed on Heroku with Docker containerization

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-------------|
| **Backend** | Ruby on Rails 8 |
| **Database** | PostgreSQL |
| **AI** | Claude API (via ruby_llm) |
| **Frontend** | Bootstrap 5, StimulusJS |
| **Auth** | Devise + JWT |
| **Deployment** | Heroku |
| **Code Quality** | Rubocop, Standard |

---

## 🚀 Quick Start

### Prerequisites
- Ruby 3.4+
- PostgreSQL 14+
- Node.js 20+

### Installation

```bash
# Clone the repository
git clone https://github.com/mtremauville/glowria.git
cd glowria

# Install dependencies
bundle install
yarn install

# Setup database
rails db:create
rails db:migrate

# Add environment variables
cp .env.example .env
# Edit .env with your Claude API key and other secrets

# Start development server
./bin/dev
```

Visit `http://localhost:3000` and sign up to try it out.

---

## 🧠 How It Works

### 1. User Signs Up
- Creates account with email/password (Devise)
- Gets authenticated via JWT

### 2. User Analyzes Skincare Products
- Enters product names or ingredients
- System queries ingredient database
- Claude API analyzes interactions

### 3. AI Generates Insights
- **Conflict Analysis:** Identifies problematic combinations
- **Safety Assessment:** Flags potential irritations
- **Efficacy Checks:** Validates ingredient synergy

### 4. Personalized Routine
- AI generates AM/PM routine recommendations
- Based on user preferences + skin type
- Optimized for maximum efficacy & safety

---

## 📋 Project Structure

```
glowria/
├── app/
│   ├── models/          # User, Product, Ingredient models
│   ├── controllers/     # Auth & API endpoints
│   ├── views/           # ERB templates (Devise, routine pages)
│   └── services/        # AIAnalysisService (Claude integration)
├── db/
│   └── migrate/         # Database schema
├── config/
│   ├── routes.rb        # Route definitions
│   └── environments/    # Rails environments
├── Dockerfile           # Container definition
├── Procfile.dev         # Development processes
└── .kamal/              # Production deployment config
```

---

## 🔑 Key Implementation Details

### Authentication Flow

```ruby
# Devise + JWT for secure authentication
# Users get JWT token on login
# Token required for API endpoints
```

### Database Schema

- **Users:** Email, encrypted password, preferences
- **Ingredients:** Name, INCI, category, properties, conflicts
- **Routines:** User routines, ingredients, AM/PM schedule
- **Analyses:** Historical ingredient analyses for users

---

## 📊 Performance & Scaling

- **Response Time:** ~800ms for AI analysis (Claude API latency)
- **Database:** PostgreSQL with proper indexing on ingredient lookups
- **Caching:** Ingredient database cached in-memory (600 entries)
- **Deployment:** Horizontal scaling ready (stateless app)

---

## 🎓 What I Learned Building This

1. **LLM Integration Patterns**
   - Structured prompting for consistent outputs
   - Error handling for API timeouts
   - Cost optimization (token counting)

2. **Rails 8 Modern Stack**
   - Hotwire (Turbo + Stimulus) for reactive UX
   - Modern asset pipeline with Importmap
   - Efficient database queries

3. **Production Deployment**
   - Deployment best practices
   - Environment variable management
   - Zero-downtime deployments with Kamal

4. **UX for Complex Domain**
   - Skincare is niche - had to research deeply
   - Ingredient interactions aren't trivial
   - User education through UI was key

---

## 🔒 Security

- ✅ Devise for secure authentication
- ✅ JWT tokens with expiration
- ✅ Environment variables for secrets (no hardcoded keys)
- ✅ CORS properly configured
- ✅ SQL injection prevention (Rails ORM)
- ✅ Password hashing with bcrypt

---

## 🚀 Deployment

Deployed on **Heroku** with:
- Docker containerization (Dockerfile)
- PostgreSQL add-on
- Environment variable configuration
- Auto-scaling ready

### Deploy Your Own
```bash
heroku create your-app-name
git push heroku main
heroku run rails db:migrate
```

---

## 📈 Future Roadmap

- [ ] Multi-language support (FR/EN/DE/ES)
- [ ] Mobile app (React Native)
- [ ] Ingredient photos (computer vision)
- [ ] Community ratings for routines
- [ ] Integration with skincare e-commerce
- [ ] Subscription tier with advanced analysis

---

## 🤝 Contributing

This is a portfolio project. If you have suggestions, feel free to open an issue!

---

## 📝 License

MIT License - Feel free to use this for learning purposes.

---

## 💬 Questions?

Built by **Mickael** - Junior AI Software Developer

- 🔗 [LinkedIn](https://linkedin.com/in/mtremauville)
- 🌐 [Portfolio](https://tremic.fr)

---

## 🎬 Demo Video

[Watch a 2-minute walkthrough of Glowria](#) - coming soon

---

**Star this repo if you like it!** ⭐
