// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//=============================================== 用户合约==================================================
contract UserContract {
    // 定义事件日志
    // event MaterialSubmitted(address indexed user, string content,uint points);
    event MaterialSubmitted(address indexed user, Materials); // 材料提交
    event UserJoinedActivity(address indexed user, uint256 activityId); // 用户参加活动

    // 用户结构体
    struct User {
        bool exists; // 用户是否存在的标志
        bool materialSubmitted; // 用户是否提交了材料的标志
        bool participatedActivity; // 用户是否参与了活动的标志
        Materials material; //申请材料
        uint256 points; // 用户积分
    }

    //材料结构体
    struct Materials {
        string _prove; //材料证明
        uint256 _points; //申请加的学分
    }
    // 映射：用户地址 => 用户信息
    mapping(address => User) public users;

    // 返回用户信息的命名元组
    function getUser(
        address _userAddress
    )
        public
        view
        returns (
            bool exists,
            bool materialSubmitted,
            bool participatedActivity,
            uint256 points,
            Materials memory
        )
    {
        User memory user = users[_userAddress];
        return (
            user.exists,
            user.materialSubmitted,
            user.participatedActivity,
            user.points,
            user.material
        );
    }

    // 查询积分函数
    function queryPoints() public view returns (uint256) {
        return users[msg.sender].points;
    }

    //===========================申请材料部分=============================

    // 提交材料函数
    function submitMaterial(string memory _content, uint256 _points) public {
        // 用户不存在时创建新用户
        if (!users[msg.sender].exists) {
            users[msg.sender] = User(true, true, false, Materials("", 0), 0);
        } else {
            users[msg.sender].materialSubmitted = true;
        }
        users[msg.sender].material._prove = _content;
        users[msg.sender].material._points = _points;
        // 触发事件日志
        //emit MaterialSubmitted(msg.sender, _content,_points);
        emit MaterialSubmitted(msg.sender, users[msg.sender].material);
    }

    //==============================参加活动部分=============================
    // 参加活动函数
    function joinActivity(address _adminContract, uint256 _activityId) public {
        AdminContract adminContract = AdminContract(_adminContract);

        // 确保管理员已经发布了活动
        require(
            adminContract.activityExists(_activityId),
            "Activity does not exist"
        );

        // 设置用户已参与活动标志为true
        users[msg.sender].participatedActivity = true;

        // 触发事件日志
        emit UserJoinedActivity(msg.sender, _activityId);
    }
}

//==================================================== 审核员合约============================================
contract ReviewerContract {
    // 定义事件日志
    event MaterialReviewed(
        address indexed reviewer,
        address indexed user,
        bool approved
    );
    event ActivityParticipationReviewed(
        address indexed reviewer,
        address indexed user,
        uint256 activityId,
        bool approved
    );

    // 映射：用户地址 => 活动ID => 是否已参与活动的标志
    mapping(address => mapping(uint256 => bool)) public participatedActivities;

    // 映射：审核员地址 => 是否审核员的标志
    mapping(address => bool) public reviewers;

    // 构造函数，注册审核员
    constructor() {
        reviewers[msg.sender] = true;
    }

    //=================================审核材料部分===================================

    // 修饰符：仅限审核员调用
    modifier onlyReviewer() {
        require(
            reviewers[msg.sender] == true,
            "Only the reviewer can perform this action"
        );
        _;
    }

    // 审核材料函数+更新对应学生学分信息
    function reviewMaterial(
        address _userContract,
        address _userAddress,
        uint _activityId,
        bool _approved
    ) public onlyReviewer {
        UserContract userContract = UserContract(_userContract);

        // 获取用户信息
        (
            bool exists,
            bool materialSubmitted,
            bool participatedActivity,
            uint256 points,
            UserContract.Materials memory material
        ) = userContract.getUser(_userAddress);

        // 确保用户已经参加了活动
        require(
            participatedActivities[_userAddress][_activityId],
            "User has not participated in the activity"
        );

        // 确保用户已经提交了材料
        require(materialSubmitted, "User has not submitted any material");

        // 触发事件日志
        emit MaterialReviewed(msg.sender, _userAddress, _approved);
    }

    //===========================================审核活动部分===========================================
    // 审核活动参与函数
    function reviewActivityParticipation(
        address _adminContract,
        address _userContract,
        address _userAddress,
        uint256 _activityId,
        bool _approved
    ) public onlyReviewer {
        AdminContract adminContract = AdminContract(_adminContract);
        UserContract userContract = UserContract(_userContract);

        // 确保管理员已经发布了活动
        require(
            adminContract.activityExists(_activityId),
            "Activity does not exist"
        );

        // 获取用户信息
        (
            bool exists,
            bool materialSubmitted,
            bool participatedActivity,
            uint256 points,
            UserContract.Materials memory material
        ) = userContract.getUser(_userAddress);

        // 确保用户参与活动
        require(
            participatedActivity,
            "User has not participated in the activity"
        );

        // 如果审核通过，则更新参与活动的标志
        if (_approved == true) {
            points += material._points;
            participatedActivities[_userAddress][_activityId] = true;
        }

        // 触发事件日志
        emit ActivityParticipationReviewed(
            msg.sender,
            _userAddress,
            _activityId,
            _approved
        );
    }
}

//========================================== 管理员合约====================================================
contract AdminContract {
    // 定义事件日志
    event ActivityPublished(address indexed admin, Activity);

    // 管理员地址
    address public admin;

    // 映射：活动ID => 活动名称
    mapping(uint256 => Activity) public activities;

    // 构造函数，初始化管理员地址
    constructor() {
        admin = msg.sender;
    }

    //========================================活动部分======================================
    //活动结构体(后续分活动类型)
    struct Activity {
        uint256 activitiy_id; //活动id
        string _name; //活动名称
        string _content; //活动内容
        bool _isExist; //活动是否存在
    }
    // 存储活动activitiesId的数组
    uint256[] public activitiesId;
    // 映射，根据activitiesId获取汽车信息
    mapping(uint256 => Activity) activityMap;

    // 修饰符：仅限管理员调用
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    // 发布活动函数
    function publishActivity(
        string memory _name,
        string memory _content
    ) public onlyAdmin {
        // 计算新的活动ID
        uint256 nowId = activitiesId.length > 0
            ? activitiesId[activitiesId.length - 1] + 1
            : 1;
        // 触发事件日志
        emit ActivityPublished(msg.sender, activityMap[nowId]);
        // 将新活动ID添加到activitiesId数组中
        activitiesId.push(nowId);
        // 初始化新车的信息
        activityMap[nowId].activitiy_id = nowId;
        activityMap[nowId]._name = _name;
        activityMap[nowId]._content = _content;
        activityMap[nowId]._isExist = true;
        // 存储活动名称
        //activities[_activityId] = _name;
    }

    // 检查活动是否存在函数
    function activityExists(uint256 _activityId) public view returns (bool) {
        return activityMap[_activityId]._isExist;
    }

    //查看统计活动数量
    function activityAmount() public view returns (uint256) {
        return activitiesId.length;
    }

    //查看对应id活动信息
    function activityInfo(
        uint256 _activityId
    ) public view returns (Activity memory) {
        return activityMap[_activityId];
    }
}
