# search-github-users

Github 사용자 즐겨찾기 앱 개발 과제 결과물입니다.

# 사용 라이브러리 / 프레임워크
- Alamofire
- SDWebImage
- RealmSwift
- RxSwift
- RxCocoa
- RxDataSources

# 설계
- Storyboard 내에서 TabBarController를 활용해서 두 개의 ViewController를 구성했습니다.
- Cocoa Touch만을 활용해서 만들었다가, RxSwift, RxCocoa를 활용하는 방법으로 변경해서 구현했습니다.
- 로컬에 즐겨찾기는 Realm을 활용해서 GithubUser 모델의 오브젝트로 저장했습니다.
- Restful API 호출은 Alamofire를 사용했으며, Github에서 검색결과를 받아오는 GithubUsers 라는 모델을 만들어서 활용했습니다.

# 향후 개선사항
RxSwift를 Button이나 Textfield같은 곳에만 부분적으로 쓰다가 TableView는 처음 적용해봤습니다.
구현할 수 있는 더 좋은 방법이 있는 것 같았고 코드도 많이 봤지만, 제가 이해할 수 있는 선 상에서 직접 구현했습니다.
Realm도 iOS Application 개발에서 사용해본 것은 이번이 처음입니다.
과제를 하면서 익숙한 방법보다는 다양한 것들을 활용해보려고 했습니다.
그래서 UITableView의 pagination이 다소 어색합니다. 이 부분을 개선하고 싶습니다.
