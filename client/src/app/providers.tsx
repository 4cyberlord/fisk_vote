"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState, useEffect } from "react";
import { ThemeProvider } from "next-themes";
import { CustomToaster } from "@/components/common/CustomToast";
import { AuthChecker } from "@/components/auth/AuthChecker";
import { initTimeSync } from "@/lib/timeService";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000, // 1 minute
            refetchOnWindowFocus: false,
            retry: 1,
          },
        },
      })
  );

  // Initialize time sync with World Time API (Nashville, TN)
  useEffect(() => {
    initTimeSync();
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider
        attribute="class"
        defaultTheme="system"
        enableSystem
        disableTransitionOnChange={false}
      >
        <AuthChecker />
        {children}
        <CustomToaster />
      </ThemeProvider>
    </QueryClientProvider>
  );
}

