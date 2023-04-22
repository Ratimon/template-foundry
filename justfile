# -------------------------------------------------------------------------------------------------
# add ./bin to PATH so the local forge-deploy binary is available
# -------------------------------------------------------------------------------------------------
export PATH := "./bin:" + env_var('PATH')
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# VERSIONS
# -------------------------------------------------------------------------------------------------
forge-deploy := "0.0.8"
forge-std := "1.5.3"
# -------------------------------------------------------------------------------------------------

_default:
  @just --choose

# example of how to setup forge-deploy as a local binary
install:
    cargo install --version {{forge-deploy}} --root . forge-deploy;
    forge install --no-git foundry-rs/forge-std@v{{forge-std}};
    forge install --no-git wighawag/forge-deploy@v{{forge-deploy}};
    ./bin/forge-deploy gen-deployer;

reinstall: uninstall install

uninstall:
    rm -Rf lib/forge-deploy;
    rm -Rf lib/forge-std;
    rm  bin/forge-deploy
    rm .crates.toml
    rm .crates2.json

compile: gen-deployer
    forge build

gen-deployer:
    forge-deploy gen-deployer

export context out:
    forge-deploy export {{context}} {{out}}

sync:
    forge-deploy sync

test: gen-deployer
    forge test

deploy $MODE="localhost": (compile)
    ldenv just _deploy
_deploy:
    if [ "${MODE}" = "void" ]; then \
        forge script script/Deploy.s.sol --private-key $DEPLOYER_PRIVATE_KEY; \
    else \
        forge script script/Deploy.s.sol --private-key $DEPLOYER_PRIVATE_KEY -vvvv --rpc-url $RPC_URL --broadcast && forge-deploy sync; \
    fi;

watch:
    watchexec -w script -w src just compile
