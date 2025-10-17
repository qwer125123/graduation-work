/********************************************************************
 * MySQL 포트폴리오용 코드
 * - 회원 관리, 로그인, 출퇴근, 위치 조회, 검색/페이지네이션
 * - Node.js 서버에서 사용하는 테이블 구조 기준
 ********************************************************************/

-- ===============================================================
-- 1️. 회원 테이블: member
-- 회원/관리자/작업자 정보 저장
-- SHA512 해시된 비밀번호 사용
-- ===============================================================
CREATE TABLE member (
    member_number INT AUTO_INCREMENT PRIMARY KEY, -- 회원 고유번호
    member_name VARCHAR(50) NOT NULL,            -- 이름
    member_phone VARCHAR(20) NOT NULL UNIQUE,    -- 전화번호
    member_password VARCHAR(128) NOT NULL,       -- SHA512 해시 비밀번호
    member_birth DATE,                           -- 생년월일
    member_gender ENUM('남','여'),               -- 성별
    member_blood VARCHAR(3),                     -- 혈액형
    member_position ENUM('관리자','일반 작업자','장비 작업자') NOT NULL, -- 직급
    member_purpose_visit VARCHAR(100),          -- 방문 목적
    member_isLeaved_company TINYINT(1) DEFAULT 0, -- 퇴사 여부
    member_attendance TINYINT(1) DEFAULT 0,       -- 출근 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 가입/등록일
);

-- ===============================================================
-- 2️. 출퇴근 기록 테이블: enter
-- 출근 시 INSERT, 퇴근 시 DELETE
-- ===============================================================
CREATE TABLE enter (
    enter_number INT AUTO_INCREMENT PRIMARY KEY, -- 출퇴근 고유번호
    member_number INT NOT NULL,                  -- 회원 번호
    enter_helmet_number VARCHAR(20) NOT NULL,   -- 헬멧 번호
    enter_tablet_number VARCHAR(20),            -- 태블릿 번호 (장비 작업자용)
    enter_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 출근 기록 시간
    FOREIGN KEY (member_number) REFERENCES member(member_number)
);

-- ===============================================================
-- 3️. 위치 기록 테이블: location
-- 작업자의 위치와 상태 기록
-- ===============================================================
CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY, -- 위치 기록 고유번호
    member_number INT NOT NULL,                 -- 회원 번호
    latitude DECIMAL(10,7),                     -- 위도
    longitude DECIMAL(10,7),                    -- 경도
    status VARCHAR(50),                          -- 작업 상태
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 기록 시간
    FOREIGN KEY (member_number) REFERENCES member(member_number)
);

-- ===============================================================
-- 4️. 샘플 데이터
-- 회원가입 예제
-- SHA512 해시 값은 Node.js에서 처리 후 삽입
-- ===============================================================
INSERT INTO member 
(member_name, member_phone, member_password, member_birth, member_gender, member_blood, member_position, member_purpose_visit, member_isLeaved_company)
VALUES 
('홍길동', '01012345678', 'HASHED_PASSWORD', '1990-01-01', '남', 'O', '일반 작업자', '현장 업무', 0),
('김관리', '01087654321', 'HASHED_PASSWORD', '1985-05-05', '여', 'A', '관리자', '관리 업무', 0);

-- 출근 기록 예제
INSERT INTO enter (member_number, enter_helmet_number) VALUES (1, 'H001');

-- 위치 기록 예제
INSERT INTO location (member_number, latitude, longitude, status) VALUES (1, 37.5665, 126.9780, '작업 중');

-- ===============================================================
-- 5️. 주요 쿼리 예제
-- ===============================================================

-- 5-1: 관리자 로그인
SELECT * FROM member
WHERE member_phone='01087654321' 
  AND member_password='HASHED_PASSWORD' 
  AND member_position='관리자';

-- 5-2: 작업자 로그인
SELECT * FROM member
WHERE member_phone='01012345678' 
  AND member_password='HASHED_PASSWORD';

-- 5-3: 출근 처리
INSERT INTO enter (member_number, enter_helmet_number) VALUES (1, 'H001');
UPDATE member SET member_attendance=1 WHERE member_number=1;

-- 5-4: 퇴근 처리
DELETE FROM enter WHERE member_number=1;
UPDATE member SET member_attendance=0 WHERE member_number=1;

-- 5-5: 작업자 목록 조회 (페이지네이션)
-- 페이지 1, 8명씩
SELECT * FROM member
WHERE member_position IN ('일반 작업자','장비 작업자')
LIMIT 0, 8;

-- 페이지 2
SELECT * FROM member
WHERE member_position IN ('일반 작업자','장비 작업자')
LIMIT 8, 8;

-- 5-6: 이름 검색 + 페이지네이션
-- 이름에 '홍' 포함, 페이지 1, 8명씩
SELECT * FROM member
WHERE member_name LIKE '%홍%'
  AND member_position IN ('일반 작업자','장비 작업자')
LIMIT 0, 8;

-- 5-7: 작업자 위치 조회
SELECT m.member_name, l.latitude, l.longitude, l.status, l.timestamp
FROM location l
JOIN member m ON l.member_number = m.member_number
ORDER BY l.timestamp DESC;
