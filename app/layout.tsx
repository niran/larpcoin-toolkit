import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Web3Provider } from "./Web3Provider";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "$CRAFT",
  description: "The testnet memecoin for builders and friends",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <Web3Provider>
      <html lang="en">
        <body className="font-mono">{children}</body>
      </html>
    </Web3Provider>
  );
}
