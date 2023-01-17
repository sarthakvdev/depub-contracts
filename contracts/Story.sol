// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./CreateActors.sol";

// Contract #2 story inherited from createActors
contract Story is CreateActors {
    constructor() {}

    address owner;

    struct chapter {
        address author;
        uint256 bookId;
        string name;
        uint256 bounty;
        string content;
        bool authorPreference;
        string question;
        mapping(address => bool) votesCasted;
        mapping(address => uint256) stake;
        address[] readers;
        uint256 chapterState;
        bool isResolved;
    }

    uint256 chapterId = 0;

    mapping(uint256 => chapter) public ChapterMapping;

    event ChapterCreated(string chapterName, string authorName);

    function createChapter(
        uint256 _bookId,
        string memory _name,
        string memory _content,
        string memory _question,
        bool _authorPreference
    ) public payable {
        require(msg.value >= 1 ether, "Keep a Bounty");
        //uint chapterCount = bookIdMapping[_bookId].chapterIdList.length;
        bookIdMapping[_bookId].chapterIdList.push(chapterId);
        ChapterMapping[chapterId].author = msg.sender;
        ChapterMapping[chapterId].bookId = _bookId;
        ChapterMapping[chapterId].name = _name;
        ChapterMapping[chapterId].bounty = msg.value;
        ChapterMapping[chapterId].content = _content;
        ChapterMapping[chapterId].question = _question;
        ChapterMapping[chapterId].authorPreference = _authorPreference;
        chapterId++;
        emit ChapterCreated(_name, authorIdMapping[msg.sender].name);
    }

    /**
        @param _bookId - Book's id you want chapters of
        @return All the chapters of a given Book by ID
    */
    function getAllChaptersOfBook(uint256 _bookId)
        public
        view
        returns (string[] memory)
    {
        uint256[] memory chaptersList = bookIdMapping[_bookId].chapterIdList;
        string[] memory chaptersOfBook = new string[](chaptersList.length);
        for (uint256 i = 0; i < chaptersList.length; i++) {
            chaptersOfBook[i] = ChapterMapping[chaptersList[i]].name;
        }
        return chaptersOfBook;
    }

    function readChapter(uint256 _chapterId) public {
        // todo: Frontend how will the owner call readChapter
        // Require(msg.sender == owner);
        // Don't push again and again
        ChapterMapping[_chapterId].readers.push(msg.sender);
    }

    /**
     * @param _chapterId - Id of chapter user is reading
     * Paying readers for reading new chapters
     */
    function payReaders(uint256 _chapterId) public {
        //require(msg.sender == owner);
        require(
            ChapterMapping[_chapterId].chapterState == 0,
            "Chapter is not new!"
        );
        uint256 bounty = (ChapterMapping[_chapterId].bounty * 5) / 100;
        address[] memory readerList = ChapterMapping[_chapterId].readers;
        uint256 numberOfReaders = readerList.length;

        // Equally distributing bounty to all the readers
        uint256 readersShare = bounty / numberOfReaders;
        // bounty = 0 ether;

        // Paying all Readers their share
        for (uint256 i = 0; i < numberOfReaders; i++) {
            payable(readerList[i]).transfer(readersShare);
        }

        // Readers have been paid
        ChapterMapping[_chapterId].chapterState = 1;
    }
    /**
     * @param _chapterId - Id of Chapter
     * @param _vote - Vote if true, Stake bounty if false
     */
    function voteForFollowup(uint256 _chapterId, bool _vote) public payable {
        uint256 bounty = msg.value;
        require(
            bounty >= 0.001 ether && bounty <= 3 ether,
            "Bounty amount needs to be within 0.001 ETH to 3 ETH"
        );
        require(
            ChapterMapping[_chapterId].chapterState < 2,
            "Voting possible only on new chapters"
        );

        if (_vote == true) {
            ChapterMapping[_chapterId].votesCasted[msg.sender] = true;
        } else {
            ChapterMapping[_chapterId].stake[msg.sender] = bounty;
        }
    }

    /**
     * @param _chapterId
     * @return winner - side of betting won
     * @return totalPool - total amount of tokens in pool (author + betting stake)
     * @return returnSum - amount of tokens to be returned
     */
    function createConsensus(uint256 _chapterId)
        internal
        view
        returns (
            bool,
            uint256,
            uint256
        )
    {
        bool winner = false;
        uint256 returnSum = 0;
        chapter storage focusChapter = ChapterMapping[_chapterId];

        // figure out proportion of winner
        uint256 totalTrueCount;
        uint256 totalFalseCount;
        uint256 totalTrueSum;
        uint256 totalFalseSum;

        for (uint256 i = 0; i < focusChapter.readers.length; i++) {
            address temp_ = focusChapter.readers[i];
            if (focusChapter.votesCasted[temp_] == true) {
                totalTrueCount++;
                totalTrueSum += focusChapter.stake[temp_];
            } else if (focusChapter.votesCasted[temp_] == false) {
                totalFalseCount++;
                totalFalseSum += focusChapter.stake[temp_];
            }
        }

        if (totalTrueSum > totalFalseSum) {
            winner = true;
            returnSum = totalTrueSum;
        } else if (totalTrueSum < totalFalseSum) {
            winner = false;
            returnSum = totalFalseSum;
        } else {
            if (totalTrueCount > totalFalseCount) {
                winner = true;
                returnSum = totalTrueSum;
            } else if (totalFalseCount > totalTrueCount) {
                winner = false;
                returnSum = totalFalseSum;
            } else {
                if (focusChapter.authorPreference == true) {
                    winner = true;
                    totalTrueSum = totalTrueSum;
                } else {
                    winner = false;
                    returnSum = totalFalseSum;
                }
            }
        }

        uint256 total_pool_author = (ChapterMapping[_chapterId].bounty * 95) /
            100;
        uint256 total_pool_betting = totalTrueSum + totalFalseSum;
        uint256 total_pool = total_pool_author + total_pool_betting;
        return (winner, total_pool, returnSum);
    }

    function makePayemntOnConsensus(uint256 _chapterId) public payable {
        chapter storage focusChapter = ChapterMapping[_chapterId];
        // This should work only if state is active and unresolved
        require(ChapterMapping[chapterId].chapterState == 0);

        (bool winner, uint256 total_pool, uint256 returnSum) = createConsensus(
            _chapterId
        );
        ChapterMapping[_chapterId].chapterState = 2;
        require(!focusChapter.isResolved, "Chapter is already resolved!");

        for (uint256 i = 0; i < focusChapter.readers.length; i++) {
            address temp_ = focusChapter.readers[i];
            if (focusChapter.votesCasted[temp_] == winner) {
                uint256 stake = focusChapter.stake[temp_];
                uint256 toPay = (stake / returnSum) * total_pool;
                payable(temp_).transfer(toPay);
            }
        }
        ChapterMapping[_chapterId].chapterState = 3; //voters have been paid
        focusChapter.isResolved = true;
    }
}
