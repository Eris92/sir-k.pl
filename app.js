"use strict";

(function () {
  const STORAGE_KEY = "sir-k-language";
  const supported = new Set(["pl", "en"]);

  function preferredLanguage() {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (supported.has(stored)) return stored;
    return navigator.language && navigator.language.toLowerCase().startsWith("en") ? "en" : "pl";
  }

  function setLanguage(language) {
    const lang = supported.has(language) ? language : "pl";
    document.documentElement.lang = lang;
    document.documentElement.dataset.lang = lang;
    document.querySelectorAll("[data-pl][data-en]").forEach((element) => {
      element.textContent = element.dataset[lang];
    });
    document.querySelectorAll("[data-lang-switch]").forEach((button) => {
      const active = button.dataset.langSwitch === lang;
      button.classList.toggle("active", active);
      button.setAttribute("aria-pressed", String(active));
    });
    document.title = lang === "pl"
      ? "Sir-K | Bezpieczeństwo i infrastruktura IT"
      : "Sir-K | IT Security and Infrastructure";
    localStorage.setItem(STORAGE_KEY, lang);
  }

  document.querySelectorAll("[data-lang-switch]").forEach((button) => {
    button.addEventListener("click", () => setLanguage(button.dataset.langSwitch));
  });

  const year = document.getElementById("year");
  if (year) year.textContent = String(new Date().getFullYear());
  setLanguage(preferredLanguage());
})();
