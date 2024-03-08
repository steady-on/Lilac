# 라일락(Lilac) - 당신과 동료들을 위한 협업 공간

| ![Auth](https://github.com/steady-on/AlgorithmStudy/assets/73203944/4adb866e-196b-4faa-a488-86376bab9171) | ![Home Default](https://github.com/steady-on/AlgorithmStudy/assets/73203944/51b546c9-7460-40a4-8ac4-2a6481de5985) | ![Workspace List](https://github.com/steady-on/AlgorithmStudy/assets/73203944/718ec317-0498-4be3-8fd7-09eabb1da835) | ![Channel Chatting](https://github.com/steady-on/AlgorithmStudy/assets/73203944/a90ba4dc-4bc9-46e5-9da8-17707258121b) | ![Coin Shop](https://github.com/steady-on/AlgorithmStudy/assets/73203944/e7f89110-f558-4b39-b546-36d89adde149) |
| --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |

## 기능 소개

1. 회원가입 & 로그인: 이메일 또는 소셜계정(애플, 카카오)을 통한 회원가입 및 로그인, Refresh Token을 사용한 Access Token 갱신, Keychain을 활용한 토큰 데이터 관리
2. 채널 목록: UICollectionViewCompositionalLayout과 DiffableDataSource를 활용한 Folable Header 구현
3. 채널 채팅: Realm을 통한 채팅 데이터 관리 및 소켓을 통한 실시간 채팅 기능
4. 코인샵: PG기반 카드 및 간편결제를 통한 코인충전

## 작업 기간 및 인원

- 개발: 2024.01.02 ~ 2024.03.01(2개월)
- iOS 1개발(백엔드/디자인 파트 협업)

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
- RequestInterceptor 통한 Header 관리 및 토큰 갱신 구현
- 소셜 로그인(애플, 카카오) 기능 구현
- Realm을 통한 채팅 데이터를 관리 및 WebSocket을 통한 실시간 채팅 기능 구현
- 실제 결제가 일어난 후 서버에 결제 인증을 확인 하는 로직 구현
- 제네릭으로 타입에 유연한 Repository를, 프로토콜을 활용한 Service 객체를 구현하여 비즈니스 로직을 체계적으로 분리
- 접근 제어, final 키워드, AnyObject 프로토콜을 사용한 성능 최적화

## 구현 시 고려사항

### 1. 서버와의 네트워크 로직을 Repository와 Service Layer로 구분하기

스웨거에서 서버의 API 명세를 봤을 때, 엄청 많은 기능들을 보면서 이걸 하나하나 전부 다 메서드로 만드는게 맞는지에 대해 고민했습니다. 어떻게 하면 효율적으로 만들 수 있을지를 고민해보았습니다. 네트워크 요청에 각각 대한 메서드를 모두 가지고 있는 객체를 만드는 것은 중복되는 코드가 많았기 때문에 비효율적이라는 생각이 들었습니다. 그래서 서버와의 직접 통신을 담당하는 레포지토리와 서버에서 제공하는 기능을 크게 6가지로 나누어 구체적인 메서드를 가지는 서비스를 만들어 역할을 구분해보았습니다.

최종적으로, 각각의 ViewModel은 필요한 Service 객체를 생성하여 메서드를 호출하기만 하면 응답 데이터가 어떤 타입으로 오는지에 대해서는 알 필요없이 메서드에서 요구하는 매개변수만 전달해주면 됩니다. 또, Service에서는 레포지토리 객체에 요청을 위한 정보와 디코딩을 위한 타입을 전달하고 나면, 네트워크 요청이나 응답의 성공/실패 여부에 관계없이 타입의 디코딩은 신경쓸 필요가 없어 각자의 기능에 충실하도록 구현할 수 있었습니다.

#### 서버 - 레포지토리 - 서비스 구조

![레포지토리 001](https://github.com/steady-on/AlgorithmStudy/assets/73203944/4b8758ae-44f5-450f-bb19-03ffbe89f24b)

#### 로그인 예시

![0250ECC3-B502-4C57-B3A3-8FF56915B640_1_201_a](https://github.com/steady-on/AlgorithmStudy/assets/73203944/f71502e7-7722-4559-ab57-a7baf3ee55fd)

### 2. Generic과 Method Overloading을 사용한 레포지토리 추상화

서버에 많은 요청을 보내는 만큼 응답데이터도 다양한 부분을 어떻게 효율적으로 처리할 수 있을지 고민했습니다. 응답 데이터의 형식에 따라 각각의 메서드를 모두 만드는 것은 비효율적이었기에, 크게 응답값이 있는 경우와 없는 경우에 대해 각각 처리하는 메서드를 만들었습니다. 이때 함수이름은 같은 것으로 오버로딩하여, Service 레이어에서 모든 요청에 대해 request 메서드를 쓰되, 응답데이터를 디코딩해야 하는 경우 추가로 `responder` 매개변수에 Decodable 타입을 넣어주기만 하면 되도록 하여 편의성도 증대시켰습니다.

#### 레포지토리 코드

```swift
struct LilacRepository<T: TargetType> {
  private let provider = MoyaProvider<T>(session: Session(interceptor: AuthInterceptor.shared))

  func request<U: Decodable>(_ api: T, responder: U.Type) -> Single<Result<U, Error>> {
    /// 네트워크 요청에 대한 응답을 처리하는 코드
  }

  func request(_ api: T) -> Single<Result<Void, Error>> {
    /// 네트워크 요청에 대한 응답을 처리하는 코드
  }
}
```

### 3. self 키워드로 Toast 알림의 위치를 View마다 다르게 해주기

Toast 메세지를 구현하면서 가장 고민했던 지점은 View마다 Toast 메세지의 위치가 조금씩 다르다는 것이었습니다. 키보드가 있을때와 없을 때, 버튼이 있으면 버튼을 가리지 않는 위치에 두어야했습니다. 필요한 모든 View에서 Toast 메세지를 띄우는 메서드를 구현하면 그때마다 적절한 위치를 잡아줄 수 있지만, 역시 코드가 반복되면서 비효율적으로 느껴져서 BaseViewController에서 구현하고 상속받는 서브 클래스에서 호출만 하면 되도록 만들고 싶었습니다. 하지만, 그렇게 구현했더니 Toast가 보여지기는 하지만, 위치를 서브 클래스에서 조정해줄 수 없다는 단점이 있었습니다. 또, 키보드가 올라오는 경우 기준이 되는 view가 BaseViewController의 view로 잡혀있어서 키보드에 제대로 대응되지 않는다는 문제도 발생했습니다. 그래서 실제 Toast가 발생하는 ViewController의 view에 Toast를 추가하고, 해당 view의 Keyboard layout을 기준으로 constraints를 잡을 수 있도록 해야했습니다.
그때 UIButton에 tap 이벤트를 처리할때 사용하는 `addTarget` 메서드가 생각났습니다. target이라는 매개변수에 `self`를 넣어주는 것으로 메서드가 호출되는 객체를 정해줄 수 있는 것처럼 Toast를 만들고 띄워주는 메서드도 매개변수를 통해 호출되는 객체를 정해주면, 해당 객체 즉, ViewController의 view에 직접 toast를 추가하고 해당 view를 기준으로 constraints를 잡아 키보드에도 대응이 가능할 것 같았습니다.

```swift
func showToast(_ toast: ToastAlert.Toast, target: BaseViewController, position: ToastAlert.Position = .low) {
    let bottonInset = switch position {
    case .high: -84
    case .low: -24
    }

    let toastMessage = ToastAlert(toast: toast)

    target.view.addSubview(toastMessage)

    toastMessage.snp.makeConstraints { make in
        make.centerX.equalTo(target.view)
        make.leading.greaterThanOrEqualTo(target.view.safeAreaLayoutGuide).inset(24)
        make.trailing.lessThanOrEqualTo(target.view.safeAreaLayoutGuide).inset(-24)
        make.bottom.equalTo(target.view.keyboardLayoutGuide.snp.top).inset(bottonInset)
    }

    target.view.layoutIfNeeded()

    UIView.animate(withDuration: 0.5, delay: 2, options: .curveLinear) {
        toastMessage.alpha = 0
        toastMessage.layoutIfNeeded()
    } completion: { _ in
        toastMessage.removeFromSuperview()
    }
}
```

그래서 이렇게 메서드를 구현하였고, 서브 클래스에서는 이 메서드를 호출해주기만 하면 아주 간단히 각 ViewController에 대한 Toast를 발생시킬 수 있었습니다.

## 회고

이번 앱은 처음으로 Figma를 통해 디자인을 받고, 컨플루언스와 스웨거를 통해 서버에 대한 API 명세를 받아 진행되었습니다. 디자인이나 서버 관련 구현을 진행하면서 궁금한 점에 대해 직접 질문을 주고 받으면서 협업을 경험할 수 있는 귀중한 경험이었습니다. 협업을 함으로써 개발에만 집중할 수 있어서 많은 View와 기능을 구현해야 했음에도 같은 기간 내에 더 효율적이고 고민을 많이하면서 작업을 할 수 있었습니다.

프로젝트를 진행하면서 Repository, Service, ViewController, ViewModel 등 많은 객체들이 의존 관계를 가지게 되었습니다. 그래서 추상화를 통해 Service 프로토콜을 작성하고, 프로토콜을 채택한 Implementary 객체를 만들거나 ViewModel의 경우는 ViewController를 생성할 때 주입을 해주는 방법으로 의존성 관리를 시도해보았습니다. 결과적으로 시간에 쫓기는 바람에 정작 ViewModel이 가지는 Service 객체의 의존성 관리는 크게 신경쓰지 못했지만, 다음에는 객체들 간의 의존성을 큰 그림으로 파악하고 의존성 주입에 신경 쓰면서 좀 더 프로토콜을 잘 활용해 보고 싶다고 생각했습니다.

또, 이번에 서버와 협업하면서 정말 많은 종류의 API 요청에 대한 메서드를 구현해야 했습니다. 이때 Workspace id처럼 여러 요청에서 중복으로 필요로 하는 연관값도 있었습니다. API 요청 하나하나를 각각의 열거형 case로 만들다보니 연관값에 대한 정의가 중복되었습니다. 해당 중복을 없애기 위해서 하나의 커다란 열거형에서 공통되는 연관값을 받고, 다른 연관값으로 중첩 열거형을 받는 경우도 고민해보았지만, 오히려 코드의 depth만 깊어질 뿐 결국 API의 path값과 같은 디테일을 설정하는 코드에서는 더 복잡해질 뿐이기만 해서 단순값의 중복이 항상 좋지 않은 것은 아니라는 것을 깨달았습니다.

더해서 요청 API가 많았던 만큼 각각의 API 응답값을 디코딩할 Model도 많이 만들어야 했습니다. Model을 하나하나 구현하면서, Service를 Auth, User, Workspace, Channel, DM, Store로 나누었던 것처럼 하나의 커다란 Response라는 열거형에 대응하는 중첩타입을 만들어서 해당 열거형 안에 구조체를 정의하는 것을 시도해 보았습니다. Service 로직을 작성할 때는 해당 중첩타입으로 타고 들어가서 타입을 가져오는 식으로 구현하면 되어서 굉장히 편했지만, Workspace에 있는 Channel 구조체가 Channel에도 구현되어야 하는 등 중복으로 정의해야 하는 경우가 있었습니다. 또 네트워킹에 사용한 모델을 그대로 사용하지 않고 ViewController에서만 사용하도록 스왑을 해서 사용했습니다. 이때도 생성자를 여러 종류로 만들어야 했어서 결과적으로 이해하기에는 쉬운 코드가 되었지만, 양적으로는 비효율적으로 커진 것 같아서 다음에는 또 다른 방법을 알아보고 시도해 보고 싶습니다.

그리고 이번에는 문서주석을 활용해서 메서드나 열거형의 case마다 간단한 설명이 자동완성 시에 보여질 수 있도록 해봤습니다. 주석 작성에도 꽤 많은 시간이 들었지만, 결과적으로 이어지는 코드를 작성할때 메서드가 정확히 어떤 기능을 하고 어떤걸 리턴하는지 등에 대한 정보를 바로 바로 확인할 수 있어서 구현시에 다시 찾아보고 확인하는 시간을 줄일 수 있었습니다. 네이밍을 한번에 알기 쉽게 하는 것도 중요하지만, 주석을 잘 활용하는 것도 협업 시 뿐만 아니라 작업의 효율을 크게 올려준다는 것을 느낄 수 있었습니다.
