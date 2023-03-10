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
        address authorAddr;
    }

    struct reader {
        string name;
        string aboutReader;
        address readerAddr;
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
    uint256 readerID = 0; // required to get total readers
    uint256 authorID = 0;

    // MAPPINGS
    mapping(address => author) public authorIdMapping;
    mapping(uint256 => address) authorIdToAddress;
    mapping(address => reader) public readerIdMapping;
    mapping(uint256 => address) public readerIdToAddress;
    mapping(uint256 => book) public bookIdMapping;
    mapping(address => book[]) public booksOfAuthor;

    function createAuthor(string memory _name, string memory _aboutAuthor)
        public
    {
        // check if author is already not in mapping
        require(
            bytes(authorIdMapping[msg.sender].name).length == 0,
            "Author already registered!"
        );

        authorIdMapping[msg.sender].name = _name;
        authorIdMapping[msg.sender].aboutAuthor = _aboutAuthor;
        authorIdMapping[msg.sender].authorAddr = msg.sender;
        authorIdToAddress[authorID] = msg.sender;
        authorID++;
        emit UserCreated("Author", _name, _aboutAuthor);
    }

    function createReader(string memory _name, string memory _aboutReader)
        public
    {
        require(
            bytes(readerIdMapping[msg.sender].name).length == 0,
            "Reader already registered!"
        );
        // check if msg.sender is not in readerIdMapping
        readerIdMapping[msg.sender].name = _name;
        readerIdMapping[msg.sender].aboutReader = _aboutReader;
        readerIdMapping[msg.sender].readerAddr = msg.sender;
        readerIdToAddress[readerID] = msg.sender;
        readerID++;
        emit UserCreated("Reader", _name, _aboutReader);
    }

    function createBook(string memory _name) public {
        // check if msg.sender exists in authorIdMapping
        require(
            bytes(authorIdMapping[msg.sender].name).length != 0,
            "Author is not registered!"
        );

        authorIdMapping[msg.sender].bookIdList.push(bookId);
        bookIdMapping[bookId].name = _name;
        bookIdMapping[bookId].authorId = msg.sender;
        bookIdMapping[bookId].bookId = bookId;
        bookId++;
        booksOfAuthor[msg.sender].push(bookIdMapping[bookId]);
        emit BookCreated(_name, authorIdMapping[msg.sender].name);
    }

    function getAllAuthors() public view returns (author[] memory) {
        // Creates an array of length authorID
        author[] memory authorsList = new author[](authorID);
        for (uint256 i = 0; i < authorID; i++) {
            address _temp = authorIdToAddress[i];
            authorsList[i] = authorIdMapping[_temp];
        }
        return authorsList;
    }

    function getAllReaders() public view returns (reader[] memory) {
        reader[] memory readersList = new reader[](readerID);
        for (uint256 i = 0; i < readerID; i++) {
            address _temp = readerIdToAddress[i];
            readersList[i] = readerIdMapping[_temp];
        }
        return readersList;
    }

    function getAllBooksOfAuthor() public view returns (string[] memory) {
        author memory focusAuthor = authorIdMapping[msg.sender];
        uint256[] memory all_books_id = focusAuthor.bookIdList;
        string[] memory bookNameList = new string[](all_books_id.length);
        // Warning: For loop over dynamic array doesn't apply as it's a view function
        for (uint256 i = 0; i < all_books_id.length; i++) {
            bookNameList[i] = bookIdMapping[all_books_id[i]].name;
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
