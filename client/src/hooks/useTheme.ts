"use client";

import { useState, useEffect, useCallback } from "react";

export type Theme = "light" | "dark" | "auto";

export function useTheme() {
  // Get resolved theme based on current theme and system preference
  const getResolvedTheme = useCallback((currentTheme: Theme): "light" | "dark" => {
    if (currentTheme === "auto") {
      if (typeof window === "undefined") return "light";
      return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }
    return currentTheme;
  }, []);

  const [theme, setThemeState] = useState<Theme>(() => {
    if (typeof window === "undefined") return "auto";
    const stored = localStorage.getItem("theme") as Theme | null;
    return stored || "auto";
  });

  const [resolvedTheme, setResolvedTheme] = useState<"light" | "dark">(() => {
    if (typeof window === "undefined") return "light";
    const initialTheme = (() => {
      const stored = localStorage.getItem("theme") as Theme | null;
      return stored || "auto";
    })();
    return getResolvedTheme(initialTheme);
  });

  // Apply theme to document
  const applyTheme = useCallback(
    (newTheme: Theme) => {
      const resolved = getResolvedTheme(newTheme);
      const root = document.documentElement;

      if (resolved === "dark") {
        root.classList.add("dark");
      } else {
        root.classList.remove("dark");
      }

      setResolvedTheme(resolved);
    },
    [getResolvedTheme]
  );

  // Set theme and persist to localStorage
  const setTheme = useCallback(
    (newTheme: Theme) => {
      setThemeState(newTheme);
      if (typeof window !== "undefined") {
        localStorage.setItem("theme", newTheme);
      }
      applyTheme(newTheme);
    },
    [applyTheme]
  );

  // Initialize theme on mount
  useEffect(() => {
    applyTheme(theme);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Only run on mount

  // Listen for system theme changes when in auto mode
  useEffect(() => {
    if (theme !== "auto") return;

    const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
    const handleChange = () => {
      const resolved = getResolvedTheme(theme);
      setResolvedTheme(resolved);
      applyTheme(theme);
    };

    // Modern browsers
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener("change", handleChange);
      return () => mediaQuery.removeEventListener("change", handleChange);
    } else {
      // Fallback for older browsers
      mediaQuery.addListener(handleChange);
      return () => mediaQuery.removeListener(handleChange);
    }
  }, [theme, getResolvedTheme, applyTheme]);

  // Update resolved theme when theme changes
  useEffect(() => {
    applyTheme(theme);
  }, [theme, applyTheme]);

  return {
    theme,
    setTheme,
    resolvedTheme,
  };
}

