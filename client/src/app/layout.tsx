import type { Metadata } from "next";
import { Heebo } from "next/font/google";
import "./globals.css";
import { Providers } from "./providers";

// Heebo font configuration - weight 500
const heebo = Heebo({
  weight: ["500"],
  subsets: ["latin"],
  variable: "--font-heebo",
  display: "swap", // Optimize font loading
});

export const metadata: Metadata = {
  title: "Fisk Voting System",
  description: "Fisk University Voting System",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={heebo.variable} suppressHydrationWarning>
      <body
        className={`${heebo.variable} antialiased`}
      >
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
