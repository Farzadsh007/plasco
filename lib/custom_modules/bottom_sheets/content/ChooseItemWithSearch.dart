import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/SelectedItemBloc.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/bars/BottomSheetSearchWidget.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/services/web.dart';

import '../../../locator.dart';
import '../../inputs/MyText.dart';

class ChooseItemWithSearchWidget extends StatefulWidget {
  ChooseItemWithSearchWidget(
      {Key key, this.selectedItemBloc, @required this.httpEvent, this.selected})
      : super(key: key);

  final SelectedItemBloc selectedItemBloc;
  final HttpEvent httpEvent;
  final DropDownItem selected;

  @override
  _ChooseItemWithSearchWidgetState createState() =>
      _ChooseItemWithSearchWidgetState(
          this.selectedItemBloc, this.httpEvent, this.selected);
}

class _ChooseItemWithSearchWidgetState
    extends State<ChooseItemWithSearchWidget> {
  _ChooseItemWithSearchWidgetState(
      this.selectedItemBloc, this.httpEvent, this.selected);

  SelectedItemBloc selectedItemBloc;
  HttpEvent httpEvent;
  MyBloc bloc = MyBloc();
  DropDownItem selected;
  List<DropDownItem> allItems;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //MyBloc bloc=MyBloc();
    if (httpEvent is DropDownProvinceGetContentEvent) {
      bloc = (httpEvent as DropDownProvinceGetContentEvent).bloc;
    } else if (httpEvent is DropDownCityGetContentEvent) {
      bloc = (httpEvent as DropDownCityGetContentEvent).bloc;
    } else if (httpEvent is DropDownGetCompanyTypeEvent) {
      bloc = (httpEvent as DropDownGetCompanyTypeEvent).bloc;
    } else if (httpEvent is DropDownGetWorkingFieldEvent) {
      bloc = (httpEvent as DropDownGetWorkingFieldEvent).bloc;
    } else if (httpEvent is DropDownGetUnitEvent) {
      bloc = (httpEvent as DropDownGetUnitEvent).bloc;
    } else if (httpEvent is DropDownGetUnitEvent) {
      bloc = (httpEvent as DropDownGetUnitEvent).bloc;
    } else if (httpEvent is DropDownGetJobTitleEvent) {
      bloc = (httpEvent as DropDownGetJobTitleEvent).bloc;
    } else if (httpEvent is DropDownGetPermissionEvent) {
      bloc = (httpEvent as DropDownGetPermissionEvent).bloc;
    } else if (httpEvent is DropDownCommunicationTypeEvent) {
      bloc = (httpEvent as DropDownCommunicationTypeEvent).bloc;
    } else if (httpEvent is DropDownGetAnomalyCategoryEvent) {
      bloc = (httpEvent as DropDownGetAnomalyCategoryEvent).bloc;
    } else if (httpEvent is DropDownGetMapCategoryListEvent) {
      bloc = (httpEvent as DropDownGetMapCategoryListEvent).bloc;
    } else if (httpEvent is DropDownGetMapCategoryListEvent) {
      bloc = (httpEvent as DropDownGetMapCategoryListEvent).bloc;
    } else if (httpEvent is DropDownGetRelatedGroupEvent) {
      bloc = (httpEvent as DropDownGetRelatedGroupEvent).bloc;
    }

    Future.delayed(Duration.zero, () {
      locator<Web>().post(httpEvent, context);
    });
  }

  @override
  void dispose() {
    // bloc.dispose();
    super.dispose();
  }

  Widget getListItem(DropDownItem item) {
    return Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
            onTap: () {
              selected = item;
              if (selectedItemBloc != null) selectedItemBloc.select(item);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              textDirection: TextDirection.rtl,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: MyText(
                    text: item.value,
                    textAlign: TextAlign.right,
                    color: ColorPalette.Black1,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                )),
                IgnorePointer(
                    child: Radio(
                  activeColor: ColorPalette.Yellow1,
                  value: item,
                  groupValue: selected,
                  onChanged: (val) {
                    //  setState(() {

                    // });
                  },
                ))
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.stream,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List<DropDownItem> list = snapshot.data as List<DropDownItem>;
           if(this.allItems==null) this.allItems=list;
            return Padding(
                padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child:Column(
              mainAxisSize: MainAxisSize.min,
              children: [

             if(httpEvent is DropDownGetWorkingFieldEvent)
                BottomSheetSearchWidget(onSearch: (search){
               bloc.add(this.allItems.where((element) => element.value.contains(search)).toList());
                },),
                Container(
                    height: 200,
                    child: SingleChildScrollView(
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
                            shrinkWrap: true,
                            itemCount: list.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return getListItem(list[index]);
                            })))
              ],
            ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
