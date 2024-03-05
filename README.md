# 라일락(Lilac) - 당신과 동료들을 위한 협업 공간

| ![Auth](https://github.com/steady-on/AlgorithmStudy/assets/73203944/4adb866e-196b-4faa-a488-86376bab9171) | ![Home Default](https://github.com/steady-on/AlgorithmStudy/assets/73203944/51b546c9-7460-40a4-8ac4-2a6481de5985) | ![Workspace List](https://github.com/steady-on/AlgorithmStudy/assets/73203944/718ec317-0498-4be3-8fd7-09eabb1da835) | ![Channel Chatting](https://github.com/steady-on/AlgorithmStudy/assets/73203944/a90ba4dc-4bc9-46e5-9da8-17707258121b) | ![Coin Shop](https://github.com/steady-on/AlgorithmStudy/assets/73203944/e7f89110-f558-4b39-b546-36d89adde149) |
| --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |

## 기능 소개

1. 회원가입 & 로그인: 이메일 또는 소셜계정(애플, 카카오)을 통해 회원가입과 로그인을 할 수 있습니다.
2. 채널 목록: 마지막에 접속한 워크스페이스의 채널 목록을 보여줍니다.
3. 워크스페이스: 워크스페이스를 생성하거나 다른 사람의 워크스페이스에 초대를 받아 참가할 수 있습니다.
4. 채널 채팅: 해당 채널에 속한 회원들과 실시간으로 채팅을 주고 받을 수 있습니다.
5. 코인샵: 코인을 충전할 수 있습니다.

## 작업 기간

- 개발: 2024.01.02 ~ 2024.03.01(2개월)

## 기술 스택

- Deployment Target: iOS 16.0
- 개발 환경: Swift 5.9, Xcode 15.2
- 프레임워크: UIKit; codebase UI
- 라이브러리:
  - SnapKit, RxSwift, KingFisher
  - Moya, Alamofire for RequestInterceptor, SocketIO
  - KakaoOpenSDK for 카카오 로그인
  - Realm, RxRealm for 채팅 데이터 관리
  - Firebase Messaging for Push Notification
  - Iamport-iOS for 결제
- 아키텍처: MVVM
- 디자인패턴: Repository Pattern, Service Mediator Pattern, Singleton Pattern
- 그 외 활용 기술: Decodable, Compositional Layout, Diffable DataSource

## 핵심 구현 요소

- RxSwift를 활용하여 반응형 UI 구현
- Interceptor를 통한 Header 관리 및 토큰 갱신 구현
- 소셜 로그인(애플, 카카오) 기능 구현
- Realm을 통한 채팅 데이터를 관리 및 WebSocket을 통한 실시간 채팅 기능 구현
- 실제 결제가 일어난 후 서버에 결제 인증을 확인 하는 로직 구현
- 제네릭으로 타입에 유연한 Repository를, 프로토콜을 활용한 Service 객체를 구현하여 비즈니스 로직을 체계적으로 분리
- 접근 제어, final 키워드, AnyObject 프로토콜을 사용한 성능 최적화

## 트러블 슈팅
