class PrudImages {
  String logo;
  String intro1;
  String intro2;
  String intro3;
  String intro4;
  String intro5;
  String intro;
  String prudIcon;
  String like;
  String dislike;
  String settings;
  String screen;
  String user;
  String err;
  String support;
  String document;

  PrudImages({
    required this.err,
    required this.logo,
    required this.intro1,
    required this.intro2,
    required this.intro3,
    required this.intro4,
    required this.intro5,
    required this.intro,
    required this.prudIcon,
    required this.like,
    required this.dislike,
    required this.screen,
    required this.settings,
    required this.user,
    required this.support,
    required this.document,
  });
}

PrudImages prudImages = PrudImages(
  dislike: 'assets/images/dislike.png',
  err: 'assets/images/err.jpg',
  intro: 'assets/images/intros/intro.jpg',
  intro1: 'assets/images/intros/intro1.jpg',
  intro2: 'assets/images/intros/intro2.jpg',
  intro3: 'assets/images/intros/intro3.jpg',
  intro4: 'assets/images/intros/intro4.jpg',
  intro5: 'assets/images/intros/intro5.jpg',
  like: 'assets/images/like.png',
  logo: 'assets/images/prud_logo.png',
  prudIcon: 'assets/images/prudapp_icon.png',
  screen: 'assets/images/gh.jpg',
  settings: 'assets/images/settings.png',
  user: 'assets/images/user.png',
  support: 'assets/images/call-center.png',
  document: 'assets/images/document.png',
);
