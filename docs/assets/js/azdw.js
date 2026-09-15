(function () {
  "use strict";

  var storageKey = "azdw-theme";
  var systemThemeQuery = window.matchMedia
    ? window.matchMedia("(prefers-color-scheme: dark)")
    : null;

  function getSystemTheme() {
    return systemThemeQuery && systemThemeQuery.matches ? "dark" : "light";
  }

  function getTheme(mode) {
    return mode === "system" ? getSystemTheme() : mode;
  }

  function applyTheme(mode) {
    var theme = getTheme(mode);

    if (window.jtd && jtd.getTheme() !== theme) {
      jtd.setTheme(theme);
    }

    var themeStylesheet = document.getElementById("azdw-theme-stylesheet");
    if (themeStylesheet) {
      var themeStylesheetHref = themeStylesheet.getAttribute("href");
      if (themeStylesheetHref) {
        themeStylesheet.setAttribute(
          "href",
          themeStylesheetHref.replace(
            /just-the-docs-(?:light|dark)\.css/,
            "just-the-docs-" + theme + ".css"
          )
        );
      }
    }

    document.documentElement.setAttribute("data-azdw-theme", theme);

    var toggle = document.getElementById("azdw-theme-toggle");
    if (toggle) {
      var nextTheme = theme === "dark" ? "light" : "dark";
      toggle.setAttribute("aria-label", "Switch to " + nextTheme + " theme");
      toggle.setAttribute("title", "Switch to " + nextTheme + " theme");
      toggle.setAttribute("aria-pressed", theme === "dark" ? "true" : "false");

      var icon = toggle.querySelector(".azdw-theme-icon");
      if (icon) {
        icon.textContent = theme === "dark" ? "\u2600" : "\u263e";
      }
    }
  }

  function readThemeMode() {
    try {
      var storedTheme = window.localStorage.getItem(storageKey);
      return storedTheme === "light" || storedTheme === "dark" ? storedTheme : "system";
    } catch (error) {
      return "system";
    }
  }

  function writeThemeMode(mode) {
    try {
      if (mode === "system") {
        window.localStorage.removeItem(storageKey);
      } else {
        window.localStorage.setItem(storageKey, mode);
      }
    } catch (error) {
      // Theme selection still works for the current page when storage is unavailable.
    }
  }

  function syncMobileHeader() {
    var controls = document.querySelector(".azdw-header-controls");
    var homeLink = document.querySelector(".azdw-home-link");
    var githubLink = document.querySelector(".azdw-github-link");
    var mobileHeader = document.querySelector(".side-bar .site-header");
    var mainHeader = document.getElementById("main-header");

    if (!controls || !homeLink || !githubLink || !mobileHeader || !mainHeader) {
      return;
    }

    var isMobile = window.matchMedia && window.matchMedia("(max-width: 49.99rem)").matches;
    var target = isMobile ? mobileHeader : mainHeader;

    if (controls.parentElement !== target) {
      target.appendChild(controls);
    }

    if (homeLink.parentElement !== target) {
      target.appendChild(homeLink);
    }

    if (githubLink.parentElement !== target) {
      target.appendChild(githubLink);
    }
  }

  function enableActiveNavLinks() {
    var currentPageUrl = window.location.pathname + window.location.search;
    var activeLinks = document.querySelectorAll(
      ".site-nav .nav-list-link.active:not([href])"
    );

    Array.prototype.forEach.call(activeLinks, function (link) {
      link.setAttribute("href", currentPageUrl);
    });
  }

  function watchActiveNavLinks() {
    var siteNav = document.querySelector(".site-nav");
    if (!siteNav) {
      return;
    }

    enableActiveNavLinks();

    if (!window.MutationObserver) {
      return;
    }

    var observer = new MutationObserver(enableActiveNavLinks);
    observer.observe(siteNav, {
      attributes: true,
      attributeFilter: ["class"],
      subtree: true
    });
  }

  function initThemeToggle() {
    var toggle = document.getElementById("azdw-theme-toggle");
    var mode = readThemeMode();

    applyTheme(mode);

    if (!toggle) {
      return;
    }

    toggle.addEventListener("click", function () {
      mode = getTheme(mode) === "dark" ? "light" : "dark";
      writeThemeMode(mode);
      applyTheme(mode);
    });

    if (systemThemeQuery) {
      var onSystemThemeChange = function () {
        if (mode === "system") {
          applyTheme(mode);
        }
      };

      if (systemThemeQuery.addEventListener) {
        systemThemeQuery.addEventListener("change", onSystemThemeChange);
      } else if (systemThemeQuery.addListener) {
        systemThemeQuery.addListener(onSystemThemeChange);
      }
    }
  }

  function slugify(text) {
    return text
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "") || "section";
  }

  function ensureHeadingId(heading) {
    if (heading.id) {
      return heading.id;
    }

    var baseId = slugify(heading.textContent);
    var id = baseId;
    var suffix = 2;

    while (document.getElementById(id)) {
      id = baseId + "-" + suffix;
      suffix += 1;
    }

    heading.id = id;
    return id;
  }

  function addInPageNavigation() {
    var main = document.querySelector("#main-content main");
    if (!main || main.querySelector(".azdw-in-page-nav")) {
      return;
    }

    var headings = Array.prototype.slice.call(main.querySelectorAll("h2, h3, h4"));
    if (headings.length < 2) {
      return;
    }

    var navigation = document.createElement("nav");
    navigation.className = "azdw-in-page-nav";
    navigation.setAttribute("aria-label", "On this page");

    var title = document.createElement("h2");
    title.className = "azdw-in-page-nav-title";
    title.textContent = "On this page";
    navigation.appendChild(title);

    var list = document.createElement("ul");
    list.className = "azdw-in-page-nav-list";
    navigation.appendChild(list);

    var topItem = document.createElement("li");
    topItem.className = "azdw-in-page-nav-top";
    var topLink = document.createElement("a");
    topLink.href = "#main-content";
    topLink.textContent = "Top of page";
    topItem.appendChild(topLink);
    list.appendChild(topItem);

    var linksById = {};

    headings.forEach(function (heading) {
      var id = ensureHeadingId(heading);
      var item = document.createElement("li");
      item.className = "azdw-in-page-nav-level-" + heading.tagName.substring(1);

      var link = document.createElement("a");
      link.href = "#" + id;
      link.textContent = heading.textContent.trim();
      item.appendChild(link);
      list.appendChild(item);
      linksById[id] = link;
    });

    main.insertBefore(navigation, main.firstChild);

    if (window.IntersectionObserver) {
      var activeHeadingId = null;

      var updateActiveLink = function (headingId) {
        var activeLink = linksById[headingId];
        if (!activeLink || activeHeadingId === headingId) {
          return;
        }

        activeHeadingId = headingId;
        Object.keys(linksById).forEach(function (id) {
          linksById[id].removeAttribute("aria-current");
        });
        activeLink.setAttribute("aria-current", "true");

        if (navigation.scrollHeight <= navigation.clientHeight) {
          return;
        }

        var navigationRect = navigation.getBoundingClientRect();
        var linkRect = activeLink.getBoundingClientRect();
        var padding = 12;

        if (linkRect.top < navigationRect.top + padding) {
          navigation.scrollTop += linkRect.top - navigationRect.top - padding;
        } else if (linkRect.bottom > navigationRect.bottom - padding) {
          navigation.scrollTop += linkRect.bottom - navigationRect.bottom + padding;
        }
      };

      var observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting || !linksById[entry.target.id]) {
            return;
          }

          updateActiveLink(entry.target.id);
        });
      }, {
        rootMargin: "-15% 0px -70% 0px",
        threshold: 0
      });

      headings.forEach(function (heading) {
        observer.observe(heading);
      });
    }
  }

  function init() {
    syncMobileHeader();
    watchActiveNavLinks();
    window.addEventListener("resize", syncMobileHeader);
    initThemeToggle();
    addInPageNavigation();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
}());