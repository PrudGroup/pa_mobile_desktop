import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:prudapp/components/page_transitions/slideright.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/home/home.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}


class SplashScreenState extends State<SplashScreen> {
  List<ContentConfig> listContentConfig = [];
  Color color = prudTheme.colorScheme.onSurface;
  ButtonStyle buttonStyle = ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return prudTheme.dividerColor;
      }
      return null; // Use the component's default.
    },

  ),);

  @override
  void initState() {
    super.initState();

    listContentConfig.add(
      ContentConfig(
        title: "",
        description: "",
        backgroundImage: prudImages.intro1,
        backgroundBlendMode: BlendMode.screen,
        backgroundImageFit: isPhone()? BoxFit.contain : BoxFit.cover,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: "",
        description: "",
        backgroundImage: prudImages.intro2,
        backgroundBlendMode: BlendMode.screen,
        backgroundImageFit: isPhone()? BoxFit.contain : BoxFit.cover,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: "",
        description: "",
        backgroundImage: prudImages.intro3,
        backgroundImageFit: isPhone()? BoxFit.contain : BoxFit.cover,
        backgroundBlendMode: BlendMode.screen,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: "",
        description: "",
        backgroundImage: prudImages.intro4,
        backgroundImageFit: isPhone()? BoxFit.contain : BoxFit.cover,
        backgroundBlendMode: BlendMode.screen,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: "",
        description: "",
        backgroundImage: prudImages.intro5,
        backgroundImageFit: isPhone()? BoxFit.contain : BoxFit.cover,
        backgroundBlendMode: BlendMode.screen,
      ),
    );
  }

  void goToHome() async {
    await myStorage.addToStore(key: 'isNew', value: false);
    if(context.mounted && mounted){
      Navigator.push(
        context,
        SlideRightRoute(page: MyHomePage(title: 'PrudApp'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgA,
      body: IntroSlider(
        // key: UniqueKey(),
        listContentConfig: listContentConfig,
        backgroundColorAllTabs: prudColorTheme.bgA,
        onDonePress: goToHome,
        onSkipPress: goToHome,
        indicatorConfig: IndicatorConfig(
          isShowIndicator: true,
          colorIndicator: color,
          colorActiveIndicator: prudTheme.primaryColor,
        ),
        skipButtonStyle: buttonStyle,
        nextButtonStyle: buttonStyle,
        doneButtonStyle: buttonStyle,
        onTabChangeCompleted: (value){
          try{
            if(mounted) {
              setState(() {
                color = (value ==0? prudTheme.primaryColor : prudTheme.colorScheme.onSurface);
              });
            }
          } catch(ex){
            debugPrint("Error: SetState Error: $ex");
          }
        },
        isShowPrevBtn: true,
        isShowDoneBtn: true,
        isShowNextBtn: true,
        isShowSkipBtn: true,
      ),
    );
  }
}
