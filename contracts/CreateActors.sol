// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "hardhat/console.sol";

// Contract #1 createActors
contract CreateActors {
    constructor() {}

    // STRUCTS
    struct author {
        string name;
        string aboutAuthor;
        uint256[] bookIdList; // List of all books by the Author
    }

    struct reader {
        string name;
        string aboutReader;
    }

    struct book {
        address authorId;
        uint256 bookId;
        string name;
        uint256[] chapterIdList;
    }

    // EVENTS
    event UserCreated(string userType, string userName, string aboutUser); // either Author or Reader
    event BookCreated(string bookName, string author);
    event HasReadBook(uint256 bookName, uint256 userName);

    uint256 bookId = 0;
    // uint readerID = 0; // Is it required?
    uint256 authorID = 0;

    // MAPPINGS
    mapping(address => author) public authorIdMapping;
    mapping(uint256 => address) authorIdToAddress;
    mapping(address => reader) public readerIdMapping;
    // mapping(uint => address) public readerIdToAddress;
    mapping(uint256 => book) public bookIdMapping;
    mapping(address => book[]) public booksOfAuthor;

    function createAuthor(string memory _name, string memory _aboutAuthor)
        public
    {
        // check if author is already not in mapping
        require(
            bytes(authorIdMapping[msg.sender].name).length == 0,
            "Author already registered."
        );
        // console.log("bytes length %s", bytes(authorIdMapping[msg.sender].name).length);

        authorIdMapping[msg.sender].name = _name;
        authorIdMapping[msg.sender].aboutAuthor = _aboutAuthor;
        authorIdToAddress[authorID] = msg.sender;
        authorID++;
        emit UserCreated("Author", _name, _aboutAuthor);
    }

    function createReader(string memory _name, string memory _aboutReader)
        public
    {
        // check if msg.sender is not in readerIdMapping
        readerIdMapping[msg.sender].name = _name;
        readerIdMapping[msg.sender].aboutReader = _aboutReader;
        // readerID++;
        emit UserCreated("Reader", _name, _aboutReader);
    }

    function createBook(string memory _name) public {
        // check if msg.sender exists in authorIdMapping
        // authorBookList[msg.sender][authorBookCount] = bookId;
        authorIdMapping[msg.sender].bookIdList.push(bookId);
        bookIdMapping[bookId].name = _name;
        bookIdMapping[bookId].authorId = msg.sender;
        bookIdMapping[bookId].bookId = bookId;
        bookId++;
        booksOfAuthor[msg.sender].push(bookIdMapping[bookId]);
        emit BookCreated(_name, authorIdMapping[msg.sender].name);
    }

    function getAllAuthors() public view returns (string[] memory) {
        // Creates an array of length authorID
        string[] memory authorsList = new string[](authorID);
        for (uint256 i = 0; i < authorID; i++) {
            address _temp = authorIdToAddress[i];
            authorsList[i] = authorIdMapping[_temp].name;
        }
        return authorsList;
    }

    function getAllBooksOfAuthor() public view returns (string[] memory) {
        author memory focusAuthor = authorIdMapping[msg.sender];
        uint256[] memory all_books_id = focusAuthor.bookIdList;
        string[] memory bookNameList = new string[](all_books_id.length);
        // Warning: For loop over dynamic array doesn't apply as it's a view function
        for (uint256 i = 0; i < all_books_id.length; i++) {
            bookNameList[i] = bookIdMapping[i].name;
        }
        return bookNameList;
    }

    function getAllBooks() public view returns (book[] memory) {
        book[] memory allBooks = new book[](bookId);
        for (uint256 i = 0; i < bookId; i++) {
            allBooks[i] = bookIdMapping[i];
        }
        return allBooks;
    }
}
