#!/bin/bash

# 현재 디렉토리 하위 모든 .md 파일 순회
find . -type f -name "*.md" | while read -r file; do
    echo "변환 중: $file"

    # 1. ![[파일명.png]] → ![](Attachments/파일명.png)
    #    - 기존 Obsidian 문법 제거하고 GitHub 호환으로 치환
    sed -E -i '
        s/!\[\[.*Attachments[\/\\]([^]]+\.(png|jpg|jpeg|gif))\]\]/![](Attachments\/\1)/g;
        s/!\[\[([^\/\]]+\.(png|jpg|jpeg|gif))\]\]/![](Attachments\/\1)/g;
    ' "$file"

    # 2. 공백을 %20으로 인코딩
    sed -E -i 's/Attachments\/([^ ]+)\ ([^)]*)/Attachments\/\1%20\2/g' "$file"
done
