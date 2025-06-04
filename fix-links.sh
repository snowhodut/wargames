#!/bin/bash

# 1. 중괄호가 포함된 이미지 파일명 수정
echo "✅ 이미지 파일명 수정 중..."
find Attachments/ -type f -name "*{*}*" | while read -r file; do
    newfile=$(echo "$file" | sed -E 's/\{([^}]+)\}/\1/')
    echo "→ $file → $newfile"
    mv "$file" "$newfile"
done

# 2. .md 파일에서 중괄호 제거된 링크로 수정
echo "✅ 마크다운 링크 수정 중..."
find . -type f -name "*.md" | while read -r mdfile; do
    sed -E -i 's/Attachments\/\{([^}]+)\}/Attachments\/\1/g' "$mdfile"
done

echo "🎉 완료됨! GitHub에서도 이미지 미리보기 잘 될 거다능 💘"
