# Dockerfile

# Python 3.11을 기반으로 한 경량 이미지 사용 (보안 패치와 pip 포함)
FROM python:3.11-slim

# Python이 .pyc 파일을 생성하지 않도록 설정 (불필요한 캐시 방지)
ENV PYTHONDONTWRITEBYTECODE 1

# 표준 입출력을 버퍼링하지 않도록 설정 (로그가 실시간 출력됨)
ENV PYTHONUNBUFFERED 1

# 컨테이너 내부의 작업 디렉토리를 /app으로 설정
WORKDIR /app

# 호스트의 app/requirements.txt 파일을 컨테이너의 현재 작업 디렉토리(/app)로 복사
COPY app/requirements.txt .

# pip를 최신으로 업그레이드한 후, 요구사항에 명시된 파이썬 패키지 설치
RUN pip install --upgrade pip && pip install -r requirements.txt

# 전체 app 디렉토리를 컨테이너 내부의 /app에 복사
COPY app .

# 컨테이너 실행 시 gunicorn 서버로 Django 애플리케이션 실행
# 'app.wsgi:application'은 wsgi.py에 정의된 application 객체를 가리킴
# 0.0.0.0:8000에서 외부 접속 허용
CMD ["gunicorn", "app.wsgi:application", "--bind", "0.0.0.0:8000"]
