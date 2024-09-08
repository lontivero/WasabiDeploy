{
  inputs = {
    systemd-nix = {
      url = github:serokell/systemd-nix;
      inputs.nixpkgs.follows = "nixpkgs"; # Make sure the nixpkgs version matches
      };

    deploy-rs.url = "github:serokell/deploy-rs";
    wasabi= { url = "github:walletwasabi/walletwasabi";    
    inputs.nixpkgs.follows = "nixpkgs"; # Make sure the nixpkgs version matches 
  };
    };

  outputs = { self, nixpkgs, wasabi, deploy-rs, systemd-nix }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    wasabi-config = pkgs.writeText "Config.json" ''
      {
        "Network": "Main",
        "BitcoinRpcConnectionString": "cookiefile=/home/lontivero/.bitcoin/.cookie",
        "MainNetBitcoinP2pEndPoint": "127.0.0.1:8333",
        "TestNetBitcoinP2pEndPoint": "127.0.0.1:18333",
        "RegTestBitcoinP2pEndPoint": "127.0.0.1:18444",
        "MainNetBitcoinCoreRpcEndPoint": "127.0.0.1:8332",
        "TestNetBitcoinCoreRpcEndPoint": "127.0.0.1:18332",
        "RegTestBitcoinCoreRpcEndPoint": "127.0.0.1:18443",
        "AnnouncerConfig": {
          "CoordinatorName": "Coordinator",
          "IsEnabled": false,
          "CoordinatorDescription": "WabiSabix Coinjoin Coordinator",
          "CoordinatorUri": "https://api.example.com/",
          "AbsoluteMinInputCount": 431,
          "ReadMoreUri": "https://api.example.com/",
          "RelayUris": [
            "wss://relay.primal.net"
          ],
        }
      }
      '';
    wasabi-backend = wasabi.packages.x86_64-linux.default;
    wasabi-service = systemd-nix.lib.x86_64-linux.mkUserService "wasabi" {
        description = "Runs Wasabi backend service";
        script = ''
          mkdir -p $HOME/.walletwasabi/backend
          cp ${wasabi-config} $HOME/.walletwasabi/backend/Config.json
          ${wasabi-backend}/bin/WalletWasabi.Backend
          '';
        serviceConfig = {
          Restart="always";
          RestartSec="10";
          Environment="DOTNET_PRINT_TELEMETRY_MESSAGE=false";
        };
      };

    bitcoind-config = pkgs.writeText "bitcoin.conf" ''
      daemon=1
      softwareexpiry=0
      whitebind=127.0.0.1:8333
      corepolicy=1
      mempoolreplacement=fee,otpin
      assumevalid=00000000000000000002f3f3e5c93ba32e7b5fc705d34613b3e58289c7f5a57f
      prune=20000
      '';
    bitcoind = pkgs.bitcoind-knots;
    bitcoind-service = systemd-nix.lib.x86_64-linux.mkUserService "bitcoin" {
        description = "Bitcoin daemon";
        script = ''
          export RPC_AUTH="$(cat ''${CREDENTIALS_DIRECTORY}/bitcoin-rpcauth)"
          ${bitcoind}/bin/bitcoind -conf=${bitcoind-config} -rpcauth=$RPC_AUTH
        '';
        serviceConfig = {
          LoadCredential="bitcoin-rpcauth:/etc/bitcoin-rpcauth";
          Type="forking";
        };
      };

  in
  {
    packages.x86_64-linux = {
      wasabi-service = wasabi-service;
      bitcoind-service = bitcoind-service;
    };
    deploy = {

      nodes.production = {
        hostname = "localhost";
        profiles.bitcoin = {
          user = "lontivero";
          path = deploy-rs.lib.x86_64-linux.activate.custom bitcoind-service "./bin/activate";
        };
        profiles.wasabi = {
          user = "lontivero";
          path = deploy-rs.lib.x86_64-linux.activate.custom wasabi-service "./bin/activate";
        };
      };
    };
  };
}

