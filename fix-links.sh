#!/bin/bash

echo "🔧 상대 경로 재계산 중..."

find . -type f -name "*.md" | while read -r mdfile; do
    # md 파일이 위치한 깊이 계산
    depth=$(echo "$mdfile" | grep -o "/" | wc -l)
    
    # 상대 경로 prefix 만들기 (../ x depth)
    relpath=""
    for ((i=1; i<depth; i++)); do
        relpath="../$relpath"
    done
    relpath="${relpath}Attachments"

    echo "→ $mdfile → 링크 경로: $relpath"

    # 실제 sed 실행: ![](Attachments/ → ![](상대경로/ 로 바꿈
    sed -E -i "s|!\[\]\(Attachments/|![]($relpath/|g" "$mdfile"
done

echo "🎉 이미지 링크 상대 경로 전환 완료!"
