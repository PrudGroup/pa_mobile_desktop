import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class ChannelSearchComponent extends StatefulWidget {
  final Function(List<VidChannel>, List<VidChannel>, String, String) onResultReady;

  const ChannelSearchComponent({super.key, required this.onResultReady});

  @override
  ChannelSearchComponentState createState() => ChannelSearchComponentState();
}

class ChannelSearchComponentState extends State<ChannelSearchComponent> {
  List<String> searchFilter = [...channelCategories, "ChannelName", "Country"];
  bool showFilter = false;
  String filterValue = "";
  bool isDark = false;
  String? searchTerm;
  bool loading = false;
  Country? selectedCountry;
  SearchController searchCtrl = SearchController();
  List<String> searchTerms = prudStudioNotifier.searchedTerms4Channel;


  @override
  void initState() {
    if(mounted) setState(() => filterValue = searchFilter[6]);
    super.initState();
    prudStudioNotifier.addListener((){
      if(mounted) setState(() => searchTerms = prudStudioNotifier.searchedTerms4Channel);
    });
  }

  @override
  void dispose() {
    prudStudioNotifier.removeListener((){});
    super.dispose();
  }

  Future<void> search() async {
    if(searchTerm != null){
      FocusManager.instance.primaryFocus?.unfocus();
      await tryAsync("search", () async {
        if(mounted) {
          setState(() {
            showFilter = false;
            loading = true;
          });
        }
        List<VidChannel> results = await prudStudioNotifier.searchForChannels(
          filterValue, searchTerm, 20, 0
        );
        if(results.isNotEmpty && filterValue == "ChannelName") prudStudioNotifier.updateSearchedTerms4Channel(searchTerm!);
        List<VidChannel> seekingResults = await prudStudioNotifier.searchForChannels(
          filterValue, searchTerm, 20, 0, onlySeeking: true
        );
        widget.onResultReady(results, seekingResults, filterValue, searchTerm!);
        if(mounted) setState(() => loading = false);
      }, 
      done: (){
        if(mounted) setState(() => loading = false);
      });
    }
  }

  void selectCountry(){
    showCountryPicker(
      context: context,
      onSelect: (country) async {
        await tryAsync("selectCountry", () async {
          if (mounted) {
            setState(() {
              selectedCountry = country;
              searchTerm = country.countryCode;
            });
            await search();
          }
        });
      },
    );
  }


  void toggleFilter(){
    if(mounted) setState(() => showFilter = !showFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            loading? LoadingComponent(
              isShimmer: false,
              defaultSpinnerType: false,
              size: 15,
              spinnerColor: prudColorTheme.primary,
            ) : IconButton(
              onPressed: toggleFilter, 
              icon: ImageIcon(AssetImage(prudImages.settings)), 
              color: prudColorTheme.primary,
            ),
            spacer.width,
            Expanded(
              child: filterValue.toLowerCase() == "country"? 
              InkWell(
                onTap: selectCountry,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Row(
                        children: [
                          if(selectedCountry != null) Text(
                            selectedCountry!.flagEmoji,
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: 20.0
                            ),
                          ),
                          spacer.width,
                          Translate(
                            text: selectedCountry != null? selectedCountry!.displayName : "Select Country",
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 20,
                      color: prudColorTheme.lineB,
                    )
                  ],
                ),
              ) 
              : 
              (
                filterValue.toLowerCase() == "channelname"? 
                SearchAnchor(
                  searchController: searchCtrl,
                  viewOnSubmitted: (String value) async {
                    searchCtrl.closeView(value);
                    if(mounted) setState(() => searchTerm = value);
                    await search();
                  },
                  builder: (BuildContext context, SearchController controller){
                    return SearchBar(
                      controller: controller,
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                      onSubmitted: (String? value) async {
                        if(mounted) setState(() => searchTerm = value);
                        await search();
                      },
                      elevation: WidgetStateProperty.all(0.0),
                      shadowColor: WidgetStateProperty.all(prudColorTheme.bgE),
                      leading: const Icon(Icons.search),
                      trailing: <Widget>[
                        Tooltip(
                          message: 'Search Channels',
                          child: IconButton(
                            isSelected: isDark,
                            onPressed: () {
                              if(mounted) setState(() => isDark = !isDark);
                            },
                            icon: const Icon(Icons.wb_sunny_outlined),
                            selectedIcon: const Icon(Icons.brightness_2_outlined),
                          ),
                        )
                      ],
                    );
                  }, 
                  suggestionsBuilder: (BuildContext context, SearchController controller){
                    return searchTerms.map<ListTile>((String term) {
                      return ListTile(
                        title: Text(term),
                        onTap: () async {
                          if(mounted) {
                            setState(() {
                              controller.closeView(term);
                              searchTerm = term;
                            });
                          }
                          await search();
                        },
                      );
                    }).toList();
                  }
                ) 
                :
                Text(
                  filterValue,
                  style: prudWidgetStyle.typedTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.secondary
                  ),
                )
              ),
            ),
          ],
        ),
        if(showFilter) spacer.height,
        if(showFilter) FormBuilderChoiceChips<String>(
          decoration: getDeco("Filter"),
          backgroundColor: prudColorTheme.bgA,
          disabledColor: prudColorTheme.bgD,
          spacing: spacer.width.width!,
          shape: prudWidgetStyle.choiceChipShape,
          selectedColor: prudColorTheme.primary,
          onChanged: (String? selected) async {
            await tryAsync("FilterSelector", () async {
              if(mounted && selected != null){
                setState(() {
                  filterValue = selected;
                  if(filterValue.toLowerCase() != "channelname" && filterValue.toLowerCase() != "country") searchTerm = selected;
                });
                if(filterValue.toLowerCase() != "channelname" && filterValue.toLowerCase() != "country") await search();
              }
            });
          },
          name: "filter",
          initialValue: filterValue,
          options: searchFilter.map((String ele) {
            return FormBuilderChipOption(
              value: ele,
              child: Translate(
                text: ele,
                style: prudWidgetStyle.btnTextStyle.copyWith(
                  color: ele == filterValue?
                  prudColorTheme.bgA : prudColorTheme.primary
                ),
                align: TextAlign.center,
              ),
            );
          }).toList(),
        ),
        spacer.height
      ],
    );
  }
}