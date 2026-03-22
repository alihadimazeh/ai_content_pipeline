● Data Models                                                                                                                                                                                 
                                                                                                                                                                                              
  User (Devise-managed)                                                                                                                                                                       
  - has_many :pipelines                                                                                                                                                                       
                                                                                                                                                                                              
  Pipeline                                                                                                                                                                                    
                                                                                                                                                                                              
  ┌─────────┬─────────────┬──────────────────────────────────────────┐                                                                                                                        
  │ Column  │    Type     │                  Notes                   │
  ├─────────┼─────────────┼──────────────────────────────────────────┤                                                                                                                        
  │ user_id │ integer     │ FK                                       │
  ├─────────┼─────────────┼──────────────────────────────────────────┤
  │ topic   │ string      │ user's input                             │
  ├─────────┼─────────────┼──────────────────────────────────────────┤                                                                                                                        
  │ formats │ jsonb/array │ e.g. ["tweet_thread", "linkedin_post"]   │
  ├─────────┼─────────────┼──────────────────────────────────────────┤                                                                                                                        
  │ status  │ string      │ pending → processing → complete / failed │
  └─────────┴─────────────┴──────────────────────────────────────────┘                                                                                                                        
                  
  GeneratedContent                                                                                                                                                                            
                  
  ┌─────────────┬─────────┬────────────────────────────────┐
  │   Column    │  Type   │             Notes              │
  ├─────────────┼─────────┼────────────────────────────────┤
  │ pipeline_id │ integer │ FK                             │
  ├─────────────┼─────────┼────────────────────────────────┤
  │ format      │ string  │ e.g. "tweet_thread"            │                                                                                                                                  
  ├─────────────┼─────────┼────────────────────────────────┤
  │ body        │ text    │ LLM output                     │                                                                                                                                  
  ├─────────────┼─────────┼────────────────────────────────┤                                                                                                                                  
  │ version     │ integer │ increments on regen, default 1 │
  ├─────────────┼─────────┼────────────────────────────────┤                                                                                                                                  
  │ status      │ string  │ pending → complete / failed    │
  └─────────────┴─────────┴────────────────────────────────┘                                                                                                                                  
   
  Relationships: User → has_many Pipelines → has_many GeneratedContents                                                                                                                       
                  
  ---                                                                                                                                                                                         
  User Flow       
           
  1. Sign up / log in via Devise
  2. New pipeline form — user types a topic, checks one or more format boxes (tweet thread, LinkedIn, blog outline, email)                                                                    
  3. Submit → controller creates Pipeline (status: pending) + one GeneratedContent per format (status: pending), enqueues a ContentGenerationJob per format                                   
  4. Redirect to pipelines#show — page renders with placeholder/spinner for each format                                                                                                       
  5. Jobs run in parallel — each calls the Anthropic API with a format-specific prompt, saves result to GeneratedContent#body, sets status to complete                                        
  6. Turbo Streams broadcast the completed content → placeholders on the page are replaced with real content, no refresh                                                                      
  7. On failure — status set to failed, error state shown with a retry button                                                                                                                 
  8. Pipeline history — index page lists all past pipelines; user can revisit any of them                                                                                                     
  9. Regenerate — per-format button re-enqueues the job, increments version                                                                                                                   
  10. Copy to clipboard — one-click copy per format output                                                                                                                                    
                                                                                                                                                                                              
  ---                                                                                                                                                                                         
  The key design choice is one job per format so they run concurrently and results trickle in independently rather than waiting for all formats to finish.                                    
                                                                                                                                                                                              
❯ explain to me the point of this application                                                                                                                                                 
                                                                                                                                                                                              
● It's a content repurposing tool powered by AI.                                                                                                                                              
                                                                                                                                                                                              
  The core idea: you have one topic or idea, but you need it packaged in multiple formats for different platforms — a tweet thread for X, a LinkedIn post, a blog outline, an email           
  newsletter. Normally you'd write each one separately, or prompt an LLM multiple times manually.                                                                                             
                                                                                                                                                                                              
  This app automates that:                                                                                                                                                                    
                                                                                                                                                                                              
  1. You type a topic once (e.g. "the benefits of walking meetings")                                                                                                                          
  2. You pick which formats you want
  3. The app generates all of them in parallel, in the background                                                                                                                             
  4. Results stream into the page as they finish                                                                                                                                              
  
  Who it's for: content creators, marketers, founders, anyone who needs to distribute the same idea across multiple channels without doing it all manually.                                   
                  
  The value: speed + consistency. One prompt → multiple platform-ready outputs, all saved in history so you can revisit, edit, or regenerate with a different tone.

---
Why version exists on GeneratedContent

When a user clicks "Regenerate" on a format, you don't want to overwrite the previous output — you want to keep a history of attempts.

So instead of updating the existing GeneratedContent record, you create a new one with an incremented version number:

- Version 1 → original generation
- Version 2 → user clicked regenerate
- Version 3 → regenerated again

This means you can:
- Show the latest version by querying ORDER BY version DESC LIMIT 1
- Keep the full history in case the user wants to compare or roll back to a previous version

Without version, regenerating would either overwrite the original (losing history) or you'd have no way to order multiple generations of the same format.
