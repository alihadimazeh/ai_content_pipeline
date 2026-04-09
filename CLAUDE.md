# AI Content Pipeline — Project Brief

## What This App Does
A full-stack Rails app where users input a topic and select content formats (tweet thread, LinkedIn post, blog outline, email newsletter). The app calls an LLM API in the background and streams results back to the UI in real time. Users can regenerate, edit, and review the history of past pipelines.

---

## Tech Stack
- **Ruby on Rails** (full-stack, not API-only)
- **Ruby** 3.2+
- **PostgreSQL** as the database
- **Devise** for authentication
- **Sidekiq + Redis** for background job processing
- **Hotwire (Turbo + Stimulus)** for real-time UI updates — no React, no separate frontend
- **Anthropic API** (claude-sonnet-4-20250514) as the LLM — use the `anthropic-rb` gem or plain Faraday/HTTParty
- **Tailwind CSS** for styling

---

## Architecture Decisions
- Full-stack Rails with Turbo Streams — keep it in one repo, no API/frontend split
- Content generation is always async via Sidekiq — never block the web request
- Use ActionCable + Turbo Streams to push results to the browser as each format completes
- One `ContentGenerationJob` per format so they can run in parallel and results trickle in independently
- Store all generated content in the DB so users have full history and can revisit past pipelines
- Use service objects for LLM calls (e.g. `LlmService`) — keep controllers thin

---

## Data Models

### User
- Managed by Devise
- `has_many :pipelines`

### Pipeline
- `belongs_to :user`
- `topic` (string) — the user's input
- `formats` (array or jsonb) — selected formats e.g. `["tweet_thread", "linkedin_post", "blog_outline", "email"]`
- `status` (string) — `pending`, `processing`, `complete`, `failed`
- `has_many :generated_contents`

### GeneratedContent
- `belongs_to :pipeline`
- `format` (string) — e.g. `"tweet_thread"`
- `body` (text) — the generated output
- `version` (integer) — increments on regeneration, default 1
- `status` (string) — `pending`, `complete`, `failed`

---

## Key Workflow (Happy Path)
1. Authenticated user fills in a topic and selects one or more formats, submits the form
2. `PipelinesController#create` creates a `Pipeline` record (status: `pending`) and one `GeneratedContent` record per selected format (status: `pending`)
3. A `ContentGenerationJob` is enqueued for each `GeneratedContent` record
4. User is redirected to `pipelines#show` which renders all formats in a pending state
5. Each job calls the LLM API with a format-specific prompt, saves the result to `GeneratedContent#body`, updates status to `complete`
6. Turbo Streams broadcasts the update — the pending placeholder on the page is replaced with the real content, no page refresh needed
7. If a job fails, status is set to `failed` and an error state is shown in the UI with a retry button

---

## Prompt Design
Each format gets its own system prompt. Keep prompts in a `Prompts` module or plain constants file (e.g. `app/lib/prompts.rb`). Example structure:

```ruby
module Prompts
  TWEET_THREAD = "You are a social media expert. Given a topic, write an engaging Twitter/X thread of 5-7 tweets..."
  LINKEDIN_POST = "You are a professional content writer. Given a topic, write a thoughtful LinkedIn post..."
  BLOG_OUTLINE = "You are a content strategist. Given a topic, write a detailed blog post outline with sections and bullet points..."
  EMAIL_NEWSLETTER = "You are an email copywriter. Given a topic, write a newsletter-style email with subject line, intro, body, and CTA..."
end
```

---

## Coding Conventions
- Thin controllers — business logic lives in service objects or jobs
- Service objects go in `app/services/` (e.g. `LlmService`, `PipelineCreator`)
- No fat models — keep models focused on associations and validations
- Background jobs in `app/jobs/`
- Prompts in `app/lib/prompts.rb`
- Avoid n+1 queries — eager load associations in controllers

---

## Key Features (in priority order)
1. Auth (Devise) — sign up, log in, log out
2. Create pipeline — topic input + format checkboxes
3. Background generation — Sidekiq jobs call LLM per format
4. Real-time UI — Turbo Streams push results as they complete
5. Pipeline history — index page showing all past pipelines
6. Regenerate — button per format to re-run generation (increments version)
7. Copy to clipboard — one-click copy per format output
8. Tone selector — dropdown (professional, casual, witty) passed into prompts

---

## UI Design Direction

This is a portfolio project — the UI should look intentional and polished.

**Aesthetic: Minimal / Developer-tool**
Think Linear, Vercel, Raycast. The generated content is the hero — the UI frames it without competing with it.

**Principles:**
- Light background, near-black text
- One accent color — muted blue or violet (fits the AI-adjacent nature of the tool)
- Strong typographic hierarchy — one font, sized deliberately
- Subtle borders and shadows — no heavy card styling
- Generous whitespace — let padding and spacing do the heavy lifting
- Clean top navbar with app name and user actions (sign out, link to pipelines)

**Styling approach:**
- Plain Tailwind CSS — no component libraries (DaisyUI, shadcn, etc.)
- Add `@tailwindcss/typography` plugin for the `prose` classes used on the `show` page where LLM output is rendered
- No ViewComponent — not needed at this scale
- Consistent page shell via `application.html.erb` — navbar + centered content column
- Each view should not define its own max-width or padding independently; inherit from the layout

**Do not start on the UI until explicitly asked.**

---

## Environment Variables Needed
```
DATABASE_URL
REDIS_URL
ANTHROPIC_API_KEY
```

---

## What's Done
- Nothing yet — greenfield project

## What's Next (start here)
- [ ] `rails new` with PostgreSQL and Tailwind
- [ ] Install and configure Devise
- [ ] Create `Pipeline` and `GeneratedContent` models with migrations
- [ ] Basic `PipelinesController` with `new`, `create`, `show`
- [ ] Set up Sidekiq and Redis
- [ ] `ContentGenerationJob` skeleton
- [ ] Wire up Turbo Stream broadcasts from the job
