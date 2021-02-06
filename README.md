# filtering_iOS
필터링 안드로이드 앱의 iOS 버전 (iOS Native, Swift)

안드로이드 버전 Repo -> https://github.com/ictechgy/filtering (React Native 사용)     
      
      
### 만들면서 어려웠던 점들
1. retain cycle 생기지 않도록 하기 - Swift와 iOS 부스트 코스에서는 야곰님이 클로저의 [weak self], [unowned self]에 대한 설명을 부가적으로 하지 않으셨었다. 그래서 직접 찾아보던 도중 https://baked-corn.tistory.com/30 블로그를 알게 되었는데 이곳의 글을 통해서 Retain cycle에 대한 전반적인 개념을 배울 수 있었다. 다만 개념을 단순히 아는 것과 실제로 적용하는 것은 큰 차이가 있었다. 이 프로젝트를 하면서 Retain cycle이 생길 것이라고 생각되는 클로저들에 weak, unowned를 직접 적용해보기는 했지만, 그것이 제대로 적용 된 것인지, 반드시 필요했던 것인지는 잘 알 수 없었다.(혼자 참조 관계를 그려보며 작성하기는 했지만..)   
2. Core Data 사용하기 - 로컬에 데이터를 저장해야하는 상황이 생겨서 'iOS에서 로컬에 데이터를 저장하는 방법'을 찾아보던 도중 Core Data를 알게 되었다. xcdatamodelId를 편집하고 적용하는 과정이 좀 어렵게 느껴졌다. (Android에서는 Room 라이브러리를 사용해서 편하게 했는데..)
   
사용한 라이브러리들  
1. 'CoreXLSX' Ver 0.14.0   
2. 'SwiftSoup' Ver 2.3.2   
3. 'XMLCoder' Ver 0.11.1
4. 'ZIPFoundation' Ver 0.9.11
5. 'Firebase', 'Firebase Storage', 'FirebaseUI Storage (with SDWebImage)'   
