# Konfiguracja Email Verification w Supabase

## Krok 1: Włącz Email Confirmation

1. Zaloguj się do [Supabase Dashboard](https://app.supabase.com)
2. Wybierz projekt GarageCrew
3. Idź do **Authentication** → **Providers**
4. Kliknij **Email** provider
5. **Włącz:** "Confirm email" (toggle ON)
6. **Zapisz** zmiany

---

## Krok 2: Skonfiguruj Email Template

1. Idź do **Authentication** → **Email Templates**
2. Wybierz **Confirm signup** template
3. Skopiuj zawartość z pliku `verification_email.html`
4. Wklej do **HTML Template** (zastępując domyślny template)
5. **Zapisz** template

---

## Krok 3: Przetestuj

1. Wyloguj się z aplikacji
2. Zarejestruj nowe konto z prawdziwym emailem
3. Sprawdź skrzynkę email
4. Kliknij "Verify My Account" w emailu
5. Powinno przekierować do aplikacji z potwierdzeniem

---

## Ważne Zmienne Template

Supabase automatycznie zastępuje następujące zmienne:

- `{{ .ConfirmationURL }}` - Link weryfikacyjny (ważny 24h)
- `{{ .Email }}` - Email użytkownika
- `{{ .Token }}` - Token weryfikacyjny
- `{{ .SiteURL }}` - URL Twojej aplikacji

**UWAGA:** Nie modyfikuj `{{ .ConfirmationURL }}` - to automatyczna zmienna Supabase!

---

## Krok 4: Redirect URL (opcjonalnie)

Jeśli chcesz przekierować użytkowników do konkretnego ekranu po weryfikacji:

1. W **Authentication** → **URL Configuration**
2. Ustaw **Redirect URLs:**
   - `garagecrew://verify` (dla deep linking w aplikacji)
   - `https://garagecrew.netlify.app/verify` (dla web)

---

## Troubleshooting

### Email nie przychodzi?
- Sprawdź folder SPAM
- Zweryfikuj że "Confirm email" jest włączone
- Sprawdź logi w **Logs** → **Auth**

### Link nie działa?
- Link jest ważny tylko 24h
- Sprawdź czy URL w Supabase settings jest poprawny
- Upewnij się że deep linking jest skonfigurowany w aplikacji

### Styling nie wyświetla się?
- Niektóre klienty email (Gmail, Outlook) mogą usuwać niektóre CSS
- Template jest zoptymalizowany dla większości klientów
- Inline styles są wspierane najlepiej

---

## Text Version (Fallback)

Supabase wymaga też tekstowej wersji emaila (dla klientów bez HTML).
Przejdź do tego samego template i ustaw **Text Template**:

```
🏁 GarageCrew - Verify Your Account

Hey there, collector!

You're just one click away from joining the ultimate Hot Wheels community!

Click this link to verify your email:
{{ .ConfirmationURL }}

What awaits you:
🏁 Organize your entire collection with photos & details
📸 Capture every model with our gallery feature
🔍 Search, filter & discover new models
👥 Connect with fellow collectors worldwide
❤️ Like & follow your favorite collections

Security First: If you didn't create an account with GarageCrew, please ignore this email.

This verification link will expire in 24 hours.

---
GarageCrew - Built by collectors, for collectors
Visit: https://garagecrew.netlify.app

© 2026 GarageCrew. All rights reserved.
```

---

## Next Steps

Po skonfigurowaniu email verification, możesz też:

1. **Password Reset Email** - Dostosuj template dla resetowania hasła
2. **Magic Link Email** - Dla logowania bez hasła
3. **Email Change Confirmation** - Gdy użytkownik zmienia email

Wszystkie template można edytować w **Authentication** → **Email Templates**.

---

✅ Po skonfigurowaniu wszystkiego, Twoi użytkownicy będą otrzymywać piękne, brandowane emaile!
