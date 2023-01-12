// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Contract #1 createActors
contract CreateActors {
    constructor() {}

    // STRUCTS
    struct author{
        string name;
        string aboutAuthor;
        uint[] bookIdList;
    }

    struct reader {
        string name;
        string aboutReader;
    }

    struct book {
        address authorId;
        uint bookId;
        string name;
        uint[] chapterIdList;
    }

    // EVENTS
    event HasReadBook(uint256 bookName, uint256 userName);
    event UserCreated(string userType, string userName, string aboutUser); // either Author or Reader
    event BookCreated(string bookName, string author);
    
    uint bookId = 0;
    // uint readerID = 0; // todo: Is it required?
    uint authorID = 0;

    // MAPPINGS
    mapping(address => author) public authorIdMapping;
    mapping(uint => address) authorIdToAddress;
    mapping(address => reader) public readerIdMapping;
    // mapping(uint => address) public readerIdToAddress;
    mapping(uint => book) public bookIdMapping;
    mapping(address => book[]) public booksOfAuthor;

    function createAuthor(string memory _name, string memory _aboutAuthor) public {
        // check if msg.sender is not in authorIdMapping
        authorIdMapping[msg.sender].name = _name;
        authorIdMapping[msg.sender].aboutAuthor = _aboutAuthor;
        authorIdToAddress[authorID] = msg.sender;
        authorID++;
        emit UserCreated("Author", _name, _aboutAuthor);
    }

    function createReader(string memory _name, string memory _aboutReader) public {
        // check if msg.sender is not in readerIdMapping
        readerIdMapping[msg.sender].name = _name;
        readerIdMapping[msg.sender].aboutReader = _aboutReader;
        // readerID++;
        emit UserCreated("Reader", _name, _aboutReader);
    }

    function createBook(string memory _name) public {
        // check if msg.sender exists in authorIdMapping
        //authorBookList[msg.sender][authorBookCount] = bookId;
        authorIdMapping[msg.sender].bookIdList.push(bookId);
        bookIdMapping[bookId].name = _name;
        bookIdMapping[bookId].authorId = msg.sender;
        bookIdMapping[bookId].bookId = bookId;
        bookId++;
        booksOfAuthor[msg.sender].push(bookIdMapping[bookId]);
        emit BookCreated(_name, authorIdMapping[msg.sender].name);
    }
    
    function getAllAuthors() view public returns (string[] memory) {
        string[] memory authorList = new string[](authorID);
        for (uint i  = 0; i < authorID; i++) {
            address _temp = authorIdToAddress[i];
            authorList[i] = authorIdMapping[_temp].name;
        }
        return authorList;
    }
    
    function getAllBooksOfAuthor() view public returns (string[] memory) {
        author memory focusAuthor = authorIdMapping[msg.sender];
        uint[] memory all_books_id = focusAuthor.bookIdList;
        string[] memory bookNameList = new string[](all_books_id.length);
        // Warning: For loop over dynamic array doesn't apply as it's a view function
        for (uint i = 0; i < all_books_id.length; i++) {
            bookNameList[i] = bookIdMapping[i].name;
        }
        return bookNameList;
    }
    
    function getAllBooks() view public returns (book[] memory) {
        book[] memory allBooks = new book[](bookId);
        for (uint i = 0; i < bookId; i++) {
            allBooks[i] = bookIdMapping[i];
        }
        return allBooks;
    }
}
