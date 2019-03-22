#include <QDebug>
#include <olm/olm.h>

#include "qolm.h"

Qolm::Qolm() {

}

/** Creates a new Olm account and generates fingerprint and identity keys. These
are returned in a json object for Qml use.
**/
QString Qolm::createAccount() {

    size_t accountSize = olm_account_size(); // Get the memory size that is at least necessary for account init

    void * accountMemory = malloc( accountSize ); // Allocate the memory

    OlmAccount* olmAccount = olm_account(accountMemory); // Initialise the olmAccount object

    size_t randomSize = olm_create_account_random_length(olmAccount); // Get the random size for account creation

    void * randomMemory = malloc( randomSize ); // Allocate the memory

    olm_create_account(olmAccount, randomMemory, randomSize); // Create the Olm account

    // Get the size for the output puffer for the identity key and save them in
    // the output buffer:
    size_t identityKeysLength = olm_account_identity_keys_length(olmAccount);
    char identityKeys[identityKeysLength];
    olm_account_identity_keys(olmAccount, identityKeys, identityKeysLength);

    return identityKeys;
}
