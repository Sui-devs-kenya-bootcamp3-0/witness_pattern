// Witness pattern
#[allow(duplicate_alias)]

module witness_pattern::my_token {
    // import libraries
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, TreasuryCap};

    // Creating a witness struct
    public struct MyToken has drop {}

    // A struct to give admin status over the token
    public struct TokenAdmin has key, store {
        id: UID,
        treasury: TreasuryCap<MyToken>  // Capability to mint new Token coins
    }

    // Initialize (create) a new coin/token
    fun init(witness: MyToken, ctx: &mut TxContext) {
       // Use Sui's coin creation function to :
       // Register a new token type(MyToken)
       // Set token info like decimal, name, symbol, description
       // Returns a treasury cap (for minting) and metadata object

       let(treasury, metadata) = coin::create_currency(
        witness, // One-time witness struct to prove we're allow to create the token
        9, // 9 decimal places
        b"B00M",  // Symbol of the token
        b"GR3RT", // Name of the token
        b"A token demonstration",  // Description
        option::none(), // Optional icon
        ctx  // Current transaction context
       );

       // To send metadata to the person who created the token
       transfer::public_transfer(metadata, tx_context::sender(ctx));

       // Create and send admin objects to the creator
       transfer::transfer(
        TokenAdmin {
            id: object::new(ctx),
            treasury
        },
        tx_context::sender(ctx)
       );
    }

    // Minting new tokens for someone holding the TokenAdmin can call this
    public entry fun mint(
        admin: &mut TokenAdmin, // Admin who has permission to mit tokens
        amount: u64,  // How many tokens to mint
        recipient: address,  // Who should receive the new tokens
        ctx: &mut TxContext     // Current transaction context
    ) {
        // Mint new token using treasury capability
        let new_coins = coin::mint(&mut admin.treasury, amount, ctx);

        // Transfer minted tokens to specified recipient
        transfer::public_transfer(new_coins, recipient);
    }
}