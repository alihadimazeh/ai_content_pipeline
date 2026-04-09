## Done
- [x] `rails new` with PostgreSQL and Tailwind
- [x] Install and configure Devise
- [x] Devise views and root route/controller
- [x] `User` model (`has_many :pipelines`)
- [x] `Pipeline` model with migration (`topic`, `formats` jsonb, `status`)
- [x] `GeneratedContent` model with migration (`format`, `body`, `version`, `status`)
- [x] All migrations run — schema up to date
- [x] Added `ruby-lsp-rails` to Gemfile (development group)

---

## To Do

### Phase 1 — Pipeline CRUD
- [x] `PipelinesController` with `new`, `create`, `show`, `index`
- [x] New pipeline form — topic text input + format checkboxes (tweet thread, LinkedIn, blog outline, email)
- [x] `PipelinesController#create` — creates `Pipeline` + one `GeneratedContent` per selected format, both with `status: pending`
- [x] `pipelines#show` — renders each format in a pending/spinner state
- [x] `pipelines#index` — pipeline history list for the current user

### Phase 2 — Background Job & LLM
- [ ] Install and configure Sidekiq + Redis
- [ ] `ContentGenerationJob` skeleton (one job per `GeneratedContent` record)
- [ ] Prompts module at `app/lib/prompts.rb` (one prompt constant per format)
- [ ] `LlmService` in `app/services/` — wraps Anthropic API call, takes format + topic, returns generated text
- [ ] Wire `ContentGenerationJob` to call `LlmService`, save result to `GeneratedContent#body`, set status to `complete` or `failed`
- [ ] Enqueue one job per format from `PipelinesController#create`
- [ ] Add Prose for LLm generated text

### Phase 3 - Tests
- [ ] Decide whether to use RSpec or MiniTest
- [ ] Add models + requests tests
- [ ] Tests for LLM Service Object and `GenereatedContent` Job 

### Phase 4 — Real-time UI (Turbo Streams)
- [ ] Broadcast Turbo Stream from job on `complete` — replace pending placeholder with generated content
- [ ] Broadcast Turbo Stream from job on `failed` — show error state with retry button
- [ ] Wire retry button to re-enqueue job (increments `version`, creates new `GeneratedContent`)

### Phase 5 — Polish & Extra Features
- [ ] Copy to clipboard button per format output
- [ ] Tone selector dropdown (professional, casual, witty) passed into prompts
- [ ] Add `confirmable` and `trackable` to Devise `User` model (check devise migration file)