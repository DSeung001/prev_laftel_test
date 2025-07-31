# Laftel Django 프로젝트

이 프로젝트는 Django, PostgreSQL, Redis, Celery를 사용하는 웹 애플리케이션입니다.

## 🚀 빠른 시작

### 사전 요구사항

- Docker Desktop 설치
- Docker Compose 설치

### 1. 프로젝트 클론 및 실행

```bash
# 프로젝트 디렉토리로 이동
cd prev_laftel_test

# 도커 컴포즈로 전체 스택 실행
docker-compose up --build
```

### 2. 브라우저에서 확인

애플리케이션이 성공적으로 실행되면 다음 URL에서 접속할 수 있습니다:
- **메인 애플리케이션**: http://localhost:8000
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## 🔧 문제 해결

### 웹 서비스가 바로 꺼지는 문제

웹 서비스가 실행되자마자 종료되는 경우 다음 사항들을 확인하세요:

#### 주요 원인과 해결방법

1. **ALLOWED_HOSTS 설정 문제** ✅ 해결됨
   - `settings.py`에서 `ALLOWED_HOSTS = ['*', 'localhost', '127.0.0.1', '0.0.0.0']`로 설정

2. **Gunicorn 미설치 문제** ✅ 해결됨
   - `requirements.txt`에 `gunicorn==21.2.0` 추가

3. **데이터베이스 연결 대기 시간 부족** ✅ 해결됨
   - PostgreSQL healthcheck 추가
   - 웹 서비스가 데이터베이스 준비 완료 후 시작하도록 설정

4. **컨테이너 재시작 정책** ✅ 해결됨
   - `restart: unless-stopped` 추가

#### 1. 데이터베이스 연결 문제
```bash
# 데이터베이스 컨테이너 상태 확인
docker-compose ps db

# 데이터베이스 로그 확인
docker-compose logs db
```

#### 2. 마이그레이션 문제
```bash
# 마이그레이션 실행
docker-compose exec web python manage.py migrate

# 마이그레이션 상태 확인
docker-compose exec web python manage.py showmigrations
```

#### 3. 정적 파일 수집
```bash
# 정적 파일 수집
docker-compose exec web python manage.py collectstatic --noinput
```

#### 4. 슈퍼유저 생성
```bash
# 관리자 계정 생성
docker-compose exec web python manage.py createsuperuser
```

### 일반적인 문제 해결

#### 포트 충돌
```bash
# 사용 중인 포트 확인
netstat -ano | findstr :8000
netstat -ano | findstr :5432

# 다른 포트로 변경하려면 docker-compose.yml 수정
```

#### 컨테이너 재시작
```bash
# 모든 컨테이너 중지 및 삭제
docker-compose down

# 볼륨까지 삭제 (데이터 초기화)
docker-compose down -v

# 다시 시작
docker-compose up --build
```

## 📁 프로젝트 구조

```
prev_laftel_test/
├── app/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── asgi.py
│   │   ├── celery.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── manage.py
│   └── requirements.txt
├── docker-compose.yml
├── Dockerfile
└── README.md
```

## 🐳 도커 서비스 설명

### Web Service (Django)
- **포트**: 8000
- **의존성**: PostgreSQL, Redis
- **기능**: Django 웹 애플리케이션 서버

### Database Service (PostgreSQL)
- **포트**: 5432
- **데이터베이스**: lafteldb
- **사용자**: laftel
- **비밀번호**: laftel

### Redis Service
- **포트**: 6379
- **기능**: Celery 브로커 및 캐시

### Celery Service
- **기능**: 백그라운드 작업 처리
- **브로커**: Redis

## 🛠️ 개발 명령어

### 도커 관련
```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs [service_name]

# 특정 서비스만 재시작
docker-compose restart [service_name]

# 컨테이너 내부 접속
docker-compose exec web bash
docker-compose exec db psql -U laftel -d lafteldb
```

### Django 관련
```bash
# Django 쉘 접속
docker-compose exec web python manage.py shell

# 마이그레이션 생성
docker-compose exec web python manage.py makemigrations

# 마이그레이션 적용
docker-compose exec web python manage.py migrate

# 정적 파일 수집
docker-compose exec web python manage.py collectstatic

# 개발 서버 실행 (로컬)
cd app
python manage.py runserver
```

## 🔍 디버깅 팁

### 1. 로그 확인
```bash
# 실시간 로그 확인
docker-compose logs -f web

# 특정 서비스 로그
docker-compose logs db
docker-compose logs redis
```

### 2. 컨테이너 내부 확인
```bash
# 웹 컨테이너 내부 접속
docker-compose exec web bash

# 데이터베이스 접속
docker-compose exec db psql -U laftel -d lafteldb
```

### 3. 네트워크 확인
```bash
# 도커 네트워크 확인
docker network ls
docker network inspect prev_laftel_test_default
```

## 📝 환경 변수

주요 환경 변수들은 `docker-compose.yml`에 정의되어 있습니다:

- `POSTGRES_DB`: lafteldb
- `POSTGRES_USER`: laftel
- `POSTGRES_PASSWORD`: laftel

## 🚨 주의사항

1. **데이터베이스 초기화**: `docker-compose down -v` 실행 시 모든 데이터가 삭제됩니다.
2. **포트 충돌**: 8000, 5432, 6379 포트가 사용 중이지 않은지 확인하세요.
3. **메모리**: Docker Desktop에 충분한 메모리를 할당하세요 (최소 4GB 권장).

## 📞 문제가 발생하면

1. 위의 문제 해결 섹션을 확인하세요
2. 로그를 확인하여 구체적인 오류 메시지를 파악하세요
3. 컨테이너를 완전히 재시작해보세요: `docker-compose down && docker-compose up --build` 