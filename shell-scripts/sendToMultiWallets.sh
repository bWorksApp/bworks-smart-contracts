
#!/bin/zsh
#zsh sendNativeToken.sh fromWallet tokenName amountToSend
#fromWallet: wallet that contains native token, tokenName: name of token to send, amountToSend: amount to send to each wallet
#./wallets.txt contains list of wallet address to receive token, each address is a new line. This file generated by js code with data from db.
#zsh sendNativeToken.sh wallet01 lovelace 1000000
#count utxo start from 0

source ./functions.sh

AMOUNT_TO_SEND=$3
TOKEN_NAME=$2
FROM_WALLET_NAME=$1

#select an utxo contains enough native token to send to all wallets
getInputTx ${FROM_WALLET_NAME}
echo ${SELECTED_UTXO}

let TX_OUTS
TX_OUT_PREFIX="--tx-out"
for wallet in "${(@f)"$(<./wallets.txt)"}"
{
  TX_OUTS="${TX_OUTS} ${TX_OUT_PREFIX} "\""${wallet}+${AMOUNT_TO_SEND} ${TOKEN_NAME}"\"""
}

createTx="$CARDANO_CLI conway transaction build  --tx-in ${SELECTED_UTXO} $(eval ${TX_OUTS}) --change-address ${SELECTED_WALLET_ADDR} --testnet-magic 1 --out-file tx.build ${TX_OUTS}"

eval ${createTx}

$CARDANO_CLI transaction sign \
--tx-body-file tx.build \
--signing-key-file ../wallets/${FROM_WALLET_NAME}.skey \
--out-file tx.signed

#$CARDANO_CLI transaction submit --tx-file tx.signed --testnet-magic $TESTNET_MAGIC_NUM

TX_HASH=$($CARDANO_CLI transaction submit --tx-file tx.signed --testnet-magic $TESTNET_MAGIC_NUM) 
DATE=$(date)
echo "Summited TxHash:" ${TX_HASH} "Date:" ${DATE}
