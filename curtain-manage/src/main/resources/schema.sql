SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 文件表
-- ----------------------------
DROP TABLE IF EXISTS sys_file;
CREATE TABLE sys_file
(
    id          int(10) unsigned NOT NULL AUTO_INCREMENT,
    path        varchar(500)     NOT NULL,
    type        varchar(10)      NOT NULL DEFAULT 'LOCAL' COMMENT 'LOCAL 本地，REMOTE 远程',
    name        varchar(100)     NOT NULL,
    extension   varchar(50)               DEFAULT NULL,
    size        int(11)                   DEFAULT NULL,
    md5         varchar(40)               DEFAULT NULL COMMENT 'md5值，防止上传重复文件',
    create_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    update_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    delete_time datetime(3)               DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY md5_del (md5, delete_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ----------------------------
-- 日志表
-- ----------------------------
DROP TABLE IF EXISTS sys_log;
CREATE TABLE sys_log
(
    id          int(10) unsigned NOT NULL AUTO_INCREMENT,
    message     varchar(450)              DEFAULT NULL,
    user_id     int(10) unsigned NOT NULL,
    username    varchar(24)               DEFAULT NULL,
    status_code int(11)                   DEFAULT NULL,
    method      varchar(20)               DEFAULT NULL,
    path        varchar(50)               DEFAULT NULL,
    permission  varchar(100)              DEFAULT NULL,
    create_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    update_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    delete_time datetime(3)               DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ----------------------------
-- 权限表
-- ----------------------------
DROP TABLE IF EXISTS sys_permission;
CREATE TABLE sys_permission
(
    id          int(10) unsigned NOT NULL AUTO_INCREMENT,
    name        varchar(60)      NOT NULL COMMENT '权限名称，例如：访问首页',
    module      varchar(50)      NOT NULL COMMENT '权限所属模块，例如：人员管理',
    mount       tinyint(1)       NOT NULL DEFAULT 1 COMMENT '0：关闭 1：开启',
    create_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    update_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    delete_time datetime(3)               DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ----------------------------
-- 分组表
-- ----------------------------
DROP TABLE IF EXISTS sys_group;
CREATE TABLE sys_group
(
    id          int(10) unsigned NOT NULL AUTO_INCREMENT,
    name        varchar(60)      NOT NULL COMMENT '分组名称，例如：搬砖者',
    info        varchar(255)              DEFAULT NULL COMMENT '分组信息：例如：搬砖的人',
    level       ENUM('root', 'guest', 'user') DEFAULT 'user' COMMENT '分组级别（root、guest分组只能存在一个）',
    create_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    update_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    delete_time datetime(3)               DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY name_del (name, delete_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ----------------------------
-- 分组-权限表
-- ----------------------------
DROP TABLE IF EXISTS sys_group_permission;
CREATE TABLE sys_group_permission
(
    id            int(10) unsigned NOT NULL AUTO_INCREMENT,
    group_id      int(10) unsigned NOT NULL COMMENT '分组id',
    permission_id int(10) unsigned NOT NULL COMMENT '权限id',
    PRIMARY KEY (id),
    KEY group_id_permission_id (group_id, permission_id) USING BTREE COMMENT '联合索引'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ----------------------------
-- 用户基本信息表
-- ----------------------------
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user
(
    id          int(10) unsigned NOT NULL AUTO_INCREMENT,
    username    varchar(24)      NOT NULL COMMENT '用户名，唯一',
    nickname    varchar(24)               DEFAULT NULL COMMENT '用户昵称',
    avatar      varchar(500)              DEFAULT NULL COMMENT '头像url',
    email       varchar(100)              DEFAULT NULL COMMENT '邮箱',
    create_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    update_time datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    delete_time datetime(3)               DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY username_del (username, delete_time),
    UNIQUE KEY email_del (email, delete_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ----------------------------
-- 用户授权信息表
# id
# user_id
# identity_type 登录类型（手机号 邮箱 用户名）或第三方应用名称（微信 微博等）
# identifier 标识（手机号 邮箱 用户名或第三方应用的唯一标识）
# credential 密码凭证（站内的保存密码，站外的不保存或保存token）
-- ----------------------------
DROP TABLE IF EXISTS sys_user_identity;
CREATE TABLE sys_user_identity
(
    id            int(10) unsigned NOT NULL AUTO_INCREMENT,
    user_id       int(10) unsigned NOT NULL COMMENT '用户id',
    identity_type varchar(100)     NOT NULL,
    identifier    varchar(100),
    credential    varchar(100),
    create_time   datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    update_time   datetime(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    delete_time   datetime(3)               DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;


-- ----------------------------
-- 用户-分组表
-- ----------------------------
DROP TABLE IF EXISTS sys_user_group;
CREATE TABLE sys_user_group
(
    id       int(10) unsigned NOT NULL AUTO_INCREMENT,
    user_id  int(10) unsigned NOT NULL COMMENT '用户id',
    group_id int(10) unsigned NOT NULL COMMENT '分组id',
    PRIMARY KEY (id),
    KEY user_id_group_id (user_id, group_id) USING BTREE COMMENT '联合索引'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ----------------------------
-- 插入超级管理员
-- 插入root分组
-- ----------------------------
BEGIN;

INSERT INTO sys_user(id, username, nickname)
VALUES (1, 'root', 'root');

INSERT INTO sys_user_identity (id, user_id, identity_type, identifier, credential)
VALUES (1, 1, 'USERNAME_PASSWORD', 'root',
        'pbkdf2sha256:64000:18:24:n:yUnDokcNRbwILZllmUOItIyo9MnI00QW:6ZcPf+sfzyoygOU8h/GSoirF');

INSERT INTO sys_group(id, name, info, level)
VALUES (1, 'root', '超级用户组', 'root');

INSERT INTO sys_group(id, name, info, level)
VALUES (2, 'guest', '游客组', 'guest');

INSERT INTO sys_user_group(id, user_id, group_id)
VALUES (1, 1, 1);

COMMIT;
