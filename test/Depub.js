const { ethers } = require("hardhat");
const { describe, it } = require("mocha");
const { expect } = require("chai");

describe("CreateActors", async () => {
  let createActors;
  let alice;
  let bob;
  let carol;
  let authorsList;
  let signers;

  it("Should create an Author", async () => {
    const CreateActors = await ethers.getContractFactory("CreateActors");
    createActors = await CreateActors.deploy();
    await createActors.deployed();

    signers = await ethers.getSigners();
    alice = signers[0];
    bob = signers[1];
    carol = signers[2];

    // Alice
    await expect(
      createActors
        .connect(alice)
        .createAuthor(
          "Alice",
          "She is an experienced author of Harry Potter Books"
        )
    )
      .to.emit(createActors, "UserCreated")
      .withArgs(
        "Author",
        "Alice",
        "She is an experienced author of Harry Potter Books"
      );

    // Bob
    await expect(
      createActors
        .connect(bob)
        .createAuthor(
          "Bob",
          "She is an experienced author of Harry Potter Books"
        )
    )
      .to.emit(createActors, "UserCreated")
      .withArgs(
        "Author",
        "Bob",
        "She is an experienced author of Harry Potter Books"
      );

    // Carol
    await expect(
      createActors
        .connect(carol)
        .createAuthor(
          "Carol",
          "She is an experienced author of Harry Potter Books"
        )
    )
      .to.emit(createActors, "UserCreated")
      .withArgs(
        "Author",
        "Carol",
        "She is an experienced author of Harry Potter Books"
      );
  });

  it("Should create a Reader", async () => {
    await expect(
      createActors
        .connect(signers[3])
        .createReader("Daniel", "Passionate about reading books!")
    )
      .to.emit(createActors, "UserCreated")
      .withArgs("Reader", "Daniel", "Passionate about reading books!");
  });

  it("Should create a Book", async () => {
    // Calling from signer alice, assigning her as the author
    await expect(createActors.connect(alice).createBook("Dark Matter"))
      .to.emit(createActors, "BookCreated")
      .withArgs("Dark Matter", "Alice");
    // Book 2 by Alice
    await expect(createActors.connect(alice).createBook("Shining"))
      .to.emit(createActors, "BookCreated")
      .withArgs("Shining", "Alice");

    // Book 1 by Bob
    await expect(createActors.connect(bob).createBook("The Stand"))
      .to.emit(createActors, "BookCreated")
      .withArgs("The Stand", "Bob");
  });

  it("Should give the list of all Authors", async () => {
    authorsList = await createActors.getAllAuthors();
    const ourAuthorsList = ["Alice", "Bob", "Carol"];

    ourAuthorsList.forEach((nameAuthor, index) => {
      expect(nameAuthor).to.equal(authorsList[index]);
    });
  });

  it("Should give list of all books by Author", async () => {
    const booksByAlice = await createActors
      .connect(alice)
      .getAllBooksOfAuthor();
    const booksByBob = await createActors.connect(bob).getAllBooksOfAuthor();

    expectedBooksByAlice = ["Dark Matter", "Shining"];
    expectedBooksByBob = ["The Stand"];

    expectedBooksByAlice.forEach((book, index) => {
      expect(book == booksByAlice[index]);
    });
    expectedBooksByBob.forEach((book, index) => {
      expect(book == booksByBob[index]);
    });
  });
});

describe("Story", async function () {
  it("Test fas fas", () => {
    console.log("This is my completed test.");
  });
});
