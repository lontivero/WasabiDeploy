# Wasabi Deploy Script

This flake uses the serokell's deploy-rs tool. It is **convenient** to build the tool first (not necessary, you can `run` the flake)

```bash
$ nix build github:serokell/deploy-rs -o deploy
```

Then simply deloy `bitcoind` and `wasabi backend` to your server:

```bash
$ ./deploy/bin/deploy --hostname=wasabi-production 

🚀 ℹ️  [deploy] [INFO] Running checks for flake in .
warning: unknown flake output 'deploy'
🚀 ℹ️  [deploy] [INFO] Evaluating flake in .
🚀 ℹ️  [deploy] [INFO] The following profiles are going to be deployed:
🚀 ℹ️  [deploy] [INFO] Building profile `wasabi` for node `production`
🚀 ℹ️  [deploy] [INFO] Building profile `bitcoin` for node `production`
🚀 ℹ️  [deploy] [INFO] Copying profile `wasabi` to node `production`
🚀 ℹ️  [deploy] [INFO] Copying profile `bitcoin` to node `production`
🚀 ℹ️  [deploy] [INFO] Activating profile `wasabi` for node `production`
🚀 ℹ️  [deploy] [INFO] Creating activation waiter
⭐ ℹ️  [activate] [INFO] Activating profile
👀 ℹ️  [wait] [INFO] Waiting for confirmation event...
⭐ ℹ️  [activate] [INFO] Activation succeeded!
⭐ ℹ️  [activate] [INFO] Magic rollback is enabled, setting up confirmation hook...
👀 ℹ️  [wait] [INFO] Found canary file, done waiting!
⭐ ℹ️  [activate] [INFO] Waiting for confirmation event...
🚀 ℹ️  [deploy] [INFO] Success activating, attempting to confirm activation
🚀 ℹ️  [deploy] [INFO] Deployment confirmed.
🚀 ℹ️  [deploy] [INFO] Activating profile `bitcoin` for node `production`
🚀 ℹ️  [deploy] [INFO] Creating activation waiter
⭐ ℹ️  [activate] [INFO] Activating profile
👀 ℹ️  [wait] [INFO] Waiting for confirmation event...
⭐ ℹ️  [activate] [INFO] Activation succeeded!
⭐ ℹ️  [activate] [INFO] Magic rollback is enabled, setting up confirmation hook...
👀 ℹ️  [wait] [INFO] Found canary file, done waiting!
⭐ ℹ️  [activate] [INFO] Waiting for confirmation event...
🚀 ℹ️  [deploy] [INFO] Success activating, attempting to confirm activation
🚀 ℹ️  [deploy] [INFO] Deployment confirmed.
```

And that's it.

# Pre-requisites

1. The server must have `nix` installed
2. `Nix` has to be in the PATH when accessed through SSH. I had to add the path to `/etc/environment`
3. You have to generate the rpcauth and put in the `/etc/bitcoin-rpcauth` file. For example
   ```
   $ cat /etc/bitcoin-rpcauth
   rpcauth=bitcoinuser:18424fdc7535831c1f7f27f08c40f8e9e$f4dc8bf1647f9c70d2945c67faa0de09a22e1d092667992eac5f104c86b26a8
   ```
