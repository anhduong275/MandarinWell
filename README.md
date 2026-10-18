# Wordwell

A small Mandarin class practice app. The static frontend deploys on GitHub Pages; Supabase provides account sign-in, the shared word bank, and private per-account practice history.

The app opens in Simplified Chinese by default. Use the language button in the header to switch between Chinese and English.

For local passwordless sign-in, the email link redirects to the deployed GitHub Pages URL. Add `https://anhduong275.github.io/MandarinWell/` (or `https://anhduong275.github.io/MandarinWell/**`) to Supabase **Authentication → URL Configuration → Redirect URLs**. The app confirms in the sign-in dialog when a verification email is sent.

## Publish with GitHub Pages

1. In this repository, open **Settings → Pages** and select **GitHub Actions** as the build and deployment source.
2. Push to the `main` branch. The workflow publishes `index.html` as the site.

The included workflow deploys the repository root. No build step or secret is needed for the static site.

## Set up shared storage and accounts

1. Open the configured Supabase project’s **SQL Editor**, paste in `supabase.sql`, and run it. This creates the shared word bank, private pick history, access policies, and starter vocabulary.
2. The app is preconfigured with the project URL and publishable key, so the shared word bank connects on page load. The key is a public client key; never put a Supabase `service_role` key in frontend code.
3. Open the deployed app and select the `?` avatar to enter your display name and email. Your teacher can create their own account on the same app.
4. Sign in by email and password, or leave the password blank to receive a passwordless sign-in link. For passwordless sign-in, add the deployed GitHub Pages address to **Authentication → URL Configuration → Redirect URLs** in Supabase.

Both accounts can read and add to the shared bank. The app only shows a signed-in user their own picks. A local preview works without Supabase, but its words and history stay in that browser and are not shared.

## App behavior

- Choose 1–50 words; the default is 10. If the bank has fewer words than requested, it picks all available words.
- Picks favor words absent from the latest three sets, then fill remaining slots from the bank.
- Pinyin and English meanings can be hidden independently.
- Add an individual word or paste multiple lines in `Chinese | pinyin | English meaning` format.
- The picker never returns the same word twice within one set.

## Data and privacy

The publishable Supabase key is intended for browser use and is restricted by the included row-level security policies. Account credentials are handled by Supabase Auth. The project URL and publishable key are part of the public frontend configuration. Shared words are visible to anyone who has the app's project configuration; only authenticated users can add them. Pick history is restricted to its owner.

To change the starter vocabulary, edit the optional inserts at the bottom of `supabase.sql` before running it. The SQL is safe to run again; duplicate characters are skipped.
