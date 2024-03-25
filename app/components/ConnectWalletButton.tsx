"use client";
import { ConnectKitButton } from "connectkit";


export default function ConnectWalletButton() {
  return (
    <ConnectKitButton.Custom>
      {({ isConnected, show, truncatedAddress, ensName }) => {
        return (
          <a className="btn btn-secondary" onClick={show}>
            {isConnected ? ensName ?? truncatedAddress : "Connect Wallet"}
          </a>
        );
      }}
    </ConnectKitButton.Custom>
  );
}
