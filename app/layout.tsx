import type { Metadata } from "next";
import { Courier_Prime } from "next/font/google";
import "./globals.css";
import { Web3Provider } from "./Web3Provider";

const monoFont = Courier_Prime({ weight: "400", subsets: ["latin"] });

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
        <body className={monoFont.className}>{children}</body>
      </html>
    </Web3Provider>
  );
}
