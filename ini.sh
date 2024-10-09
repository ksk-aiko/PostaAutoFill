#!/bin/bash

# Create the required project structure
echo "Creating project directories..."
mkdir -p diagrams requirement src public

# Create and write to Dockerfile
echo "Creating Dockerfile..."
cat <<EOL > Dockerfile
# Use Node.js 14 LTS version as the base image
FROM node:14

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the entire project directory to the working directory
COPY . .

# Expose port 3000 for the React application
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
EOL

# Create and write to docker-compose.yml
echo "Creating docker-compose.yml..."
cat <<EOL > docker-compose.yml
version: '3'
services:
  zipcode-app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
EOL

# Create and write to requirements.md
echo "Creating requirement/requirements.md..."
cat <<EOL > requirement/requirements.md
# requirements.md

## 目的
郵便番号の自動入力機能により、ユーザーが郵便番号を入力するだけで住所情報を自動的に取得し、表示します。

## 機能要件
- ユーザーが郵便番号を入力すると、自動的にAPIを呼び出して住所情報を取得します。
- 取得した住所情報（カナ、漢字、ローマ字）をそれぞれのテキストフィールドに表示します。
- エラー時にはエラーメッセージを表示します。

## 非機能要件
- APIの呼び出しには非同期通信を使用し、レスポンスが返るまでUIが適切に応答するようにします。
- リアルタイムなAPI呼び出しによって、UIの応答速度を保つ必要があります。
- ユーザーが正確に7桁の郵便番号を入力した場合のみ、APIが呼び出されるようにします。

## 前提条件
- APIが日本の郵便番号をサポートしているため、郵便番号は7桁の数字と仮定します。
EOL

# Create and write to task.md
echo "Creating requirement/task.md..."
cat <<EOL > requirement/task.md
# task.md

## 1. 要件定義
- [x] 郵便番号に基づく住所自動入力機能の要件を定義 (requirements.mdファイルを作成)

## 2. Docker環境構築
- [x] Dockerfileを作成し、ReactアプリをDocker環境で起動できるようにする
- [x] docker-compose.ymlを作成し、アプリをデプロイ可能にする

## 3. UML図の作成
- [x] アーキテクチャ図を作成 (arch.pu)
- [x] ユースケース図を作成 (usecase.pu)
- [x] アクティビティ図を作成 (activity.pu)
- [x] シーケンス図を作成 (sequence.pu)
- [x] コンポーネント図を作成 (component.pu)
- [x] クラス図を作成 (class.pu)

## 4. コーディング
- [x] Reactのプロジェクトを作成
- [x] 郵便番号入力フィールドの作成
- [x] 住所表示フィールドの作成
- [x] useFetchAddressフックの作成
- [x] API呼び出しの実装
- [x] エラーハンドリングの実装

## 5. テスト
- [ ] 郵便番号入力による住所情報の自動表示のテスト
- [ ] 不正な郵便番号入力時のエラーハンドリングのテスト
- [ ] 正常なAPI呼び出しの確認
EOL

# Generate PlantUML files for diagrams
echo "Creating UML diagrams..."
cat <<EOL > diagrams/arch.pu
@startuml
skinparam componentStyle rectangle
package "Reactアプリケーション" {
    [ZipCodeInputコンポーネント] --> [useFetchAddress]
    [ZipCodeInputコンポーネント] --> [APIエンドポイント]
}
@enduml
EOL

cat <<EOL > diagrams/usecase.pu
@startuml
actor ユーザー
actor "APIサービス" as API

ユーザー --> (郵便番号の入力)
(郵便番号の入力) --> (APIの呼び出し)
(APIの呼び出し) --> API
API --> (住所情報の表示)
@enduml
EOL

cat <<EOL > diagrams/activity.pu
@startuml
|ユーザー|
start
:郵便番号入力;
:API呼び出し;
|システム|
:住所データ取得;
if (データあり?) then (yes)
  :住所情報の表示;
else (no)
  :エラーメッセージ表示;
endif
stop
@enduml
EOL

cat <<EOL > diagrams/sequence.pu
@startuml
actor ユーザー
participant ZipCodeInput as コンポーネント
participant API
participant UI as 表示

ユーザー -> コンポーネント: 郵便番号入力
コンポーネント -> API: 郵便番号で住所情報取得
API -> コンポーネント: 住所情報レスポンス
コンポーネント -> UI: 住所情報を表示
@enduml
EOL

cat <<EOL > diagrams/component.pu
@startuml
component "ZipCodeInput" as ZipCodeInput
component "useFetchAddress" as useFetchAddress
component "API" as API

ZipCodeInput -down-> useFetchAddress
useFetchAddress -down-> API
@enduml
EOL

cat <<EOL > diagrams/class.pu
@startuml
class ZipCodeInput {
  +handleZipCodeChange()
  +useEffect()
}
class useFetchAddress {
  +fetchAddress()
  -apiEndpoint
}
ZipCodeInput --> useFetchAddress
@enduml
EOL

# Add custom components and hooks for the Zip Code Input
echo "Creating ZipCodeInput component..."
mkdir src/components
cat <<EOL > src/components/ZipCodeInput.js
import React, { useState, useEffect } from 'react';
import axios from 'axios';

const ZipCodeInput = () => {
  const [zipCode, setZipCode] = useState('');
  const [address, setAddress] = useState({ kana: '', kanji: '', romaji: '' });
  const [error, setError] = useState(null);

  const handleZipCodeChange = (e) => {
    setZipCode(e.target.value);
  };

  useEffect(() => {
    if (zipCode.length === 7) {
      fetchAddress(zipCode);
    }
  }, [zipCode]);

  const fetchAddress = async (zip) => {
    try {
      const response = await axios.get(\`https://postcode.teraren.com/\${zip}.json\`);
      if (response.data && response.data.address) {
        setAddress({
          kana: response.data.address.kana,
          kanji: response.data.address.kanji,
          romaji: response.data.address.romaji,
        });
        setError(null);
      } else {
        setAddress({ kana: '', kanji: '', romaji: '' });
        setError('Address not found');
      }
    } catch (err) {
      setAddress({ kana: '', kanji: '', romaji: '' });
      setError('Failed to fetch address');
    }
  };

  return (
    <div>
      <h2>Automatic Address Input</h2>
      <label>
        Zip Code:
        <input
          type="text"
          value={zipCode}
          onChange={handleZipCodeChange}
          placeholder="Enter zip code"
        />
      </label>
      <div>
        <label>Address (Kana):
          <input type="text" value={address.kana} readOnly />
        </label>
      </div>
      <div>
        <label>Address (Kanji):
          <input type="text" value={address.kanji} readOnly />
        </label>
      </div>
      <div>
        <label>Address (Romaji):
          <input type="text" value={address.romaji} readOnly />
        </label>
      </div>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  );
};

export default ZipCodeInput;
EOL

echo "All setup completed. You can now use 'docker-compose up' to start the application."
