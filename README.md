# filtering_iOS
'필터링' 안드로이드 앱의 iOS 버전 (iOS Native, Swift)

안드로이드 버전 Repo -> https://github.com/ictechgy/filtering (React Native 사용)     
      
&nbsp;   
      
## 🤔 본 어플리케이션을 만들게된 계기 (What made me create this application?)
React Native로 만들었던 안드로이드 앱을 Swift로 구현해보자
   
&nbsp;   
   
## 💻 개발 기간 (Development Period)
   
&nbsp;   
   
## 📚 사용한 라이브러리 (Used libraries)  

1. 'CoreXLSX' Ver 0.14.0   
2. 'SwiftSoup' Ver 2.3.2   
3. 'XMLCoder' Ver 0.11.1
4. 'ZIPFoundation' Ver 0.9.11
5. 'Firebase', 'Firebase Storage', 'FirebaseUI Storage (with SDWebImage)'
   
&nbsp;   
   
## 🚀 사용했거나 사용하려 했던 패턴/스킬 (Used Or Tried Patterns And Skills)
1. Delegate 패턴   
2. CoreData   
즐겨찾기 저장용   
3. Custom View   
UIDropDownView - ref: ['Prathamesh Salvi' medium blog, license: MIT](http://medium.com/@prathamsalvi27/ios-swift-dropdown-menu-3b2a69c34b23)   
 
   
&nbsp;   
   
## 💦 만들면서 힘들었던 점 (Difficulties)

1. retain cycle 생기지 않도록 하기   
 Swift와 iOS 부스트 코스에서는 야곰님이 클로저의 [weak self], [unowned self]에 대한 설명을 부가적으로 하지 않으셨었다. 그래서 직접 찾아보던 도중 https://baked-corn.tistory.com/30 블로그를 알게 되었는데 이곳의 글을 통해서 Retain cycle에 대한 전반적인 개념을 배울 수 있었다. 다만 개념을 단순히 아는 것과 실제로 적용하는 것은 큰 차이가 있었다. 이 프로젝트를 하면서 Retain cycle이 생길 것이라고 생각되는 클로저들에 weak, unowned를 직접 적용해보기는 했지만, 그것이 제대로 적용 된 것인지, 반드시 필요했던 것인지는 잘 알 수 없었다.(혼자 참조 관계를 그려보며 작성하기는 했지만..)    
 - 특히 클로저를 일급객체처럼 취급하면서 이곳 저곳으로 넘기는 과정에서도 retain cycle은 고려해야 할 것 같았어서..    
   
2. Core Data 사용하기
 로컬에 데이터를 저장해야하는 상황이 생겨서 'iOS에서 로컬에 데이터를 저장하는 방법'을 찾아보던 도중 Core Data를 알게 되었다. xcdatamodelId를 편집하고 적용하는 과정이 좀 어렵게 느껴졌다. (Android에서는 Room 라이브러리를 사용해서 편하게 했는데..) https://zeddios.tistory.com/987 zeddiOS 블로그를 많이 참조하였다. (NS 접두어가 붙은 클래스들을 다루는 것도 조금 생소했다.)   
   
3. Storyboard에서 Constraint 설정하기   
 정말 많이 힘들었던 부분이다. Android와는 사뭇 설정방식이 다르다보니 많이 헤맸다.. 제대로 맞게 설정한 것 같은데 시뮬레이터로 구동해보면 이상하게 나온다던지, 다른 기기로 켜보면 클리핑된다던지..
 현업에서는 코드로 구성하는 방식도 많이 쓴다는데 아마도.. 스토리보드를 통해서는 어떤 제약조건이 어떻게 설정되었는지 바로바로 알기 어려워서 그런 것 아닐까..?
 
4. Custom View 만들기   
 UIDropDownView라는 커스텀 뷰를 직접 만들었는데 http://medium.com/@prathamsalvi27/ios-swift-dropdown-menu-3b2a69c34b23 블로그를 참조하여 만들었다.(MIT License) UITableView를 이용하여 콤보박스를 만들었는데, TableView에 별도의 TableViewCell xib를 만들어 적용할 때에는 UINib으로서 register해줘야 한다는 것을 알 수 있었다.    
   
5. 다크모드 지원   
6. 언제 Dispatch Queue를 쓰고 언제 Operation Queue를 쓸 것인지   
 비동기 작업에 대해 React Native를 이용했을 때에는 Async Await, Android에서는 Async Task(deprecated)나 Excutors, ThreadPool을 썼었다.   
 
7. 즐겨찾기 목록화면에서 Editing 모드 때 아이템을 삭제할 수 있도록 구현   
 tableView의 didSelectRowAt 메소드를 쓰지 않고 GestureRecognizer를 직접 add해서 다음 VC로 넘기는 작업을 구성했었는데 이게 Editing 모드에서도 cell이 selected 되는게 아니라 다음 화면으로 넘어가게 작동이 됬었다.. 때문에 editing모드일 때는 cell 선택이 되도록 해주는 작업을 해줬었는데 이후 선택된 셀의 인덱스를 Set에 저장하고 처리하는 작업까지 해주었다. 그런데 보니까.. tableView에 indexPathForSelectedRows 프로퍼티가 있더라. 쉽게 구현할 수 있었던 항목들을 괜히 어렵게 구현한 것 같다. Developer Documentation을 잘 살펴보도록 하자
   
   
&nbsp;   
   
## 💬 기능(사용법) 
   
&nbsp;   
   
## 🛠 개선해야할 점/추가했으면 하는 기능 (Needs to be improved / Want to add)
1. 지나친 Massive ViewController   
대부분의 기능을 ViewController에 두다보니 VC가 지나치게 무거워졌다. 
2. 코드 작성에 기준이 부족했고 난잡   
필요한 기능을 단순히 구현하려고만 하다보니 뒤죽박죽 스파게티 코드가 되어버렸다. 유지보수, 디버깅에 어려움이 많다.
   
&nbsp;   
   
## 📝 Information
   
&nbsp;   
   
