import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';

import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ApproveRelatedCompany.dart';

import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import 'package:plasco/views/relatedCompany/NewRelatedCompanyPageWidget.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class RelatedCompanyPageWidget extends StatefulWidget {
  @override
  _RelatedCompanyPageWidgetState createState() =>
      _RelatedCompanyPageWidgetState();
}

class _RelatedCompanyPageWidgetState extends State<RelatedCompanyPageWidget> with SingleTickerProviderStateMixin{
  MyBloc httpBloc =locator<Constants>().relatedCompanyListHttpBloc;
  ScrollController _scrollController = ScrollController();
  AnimationController _hideFabAnimController;
  MyBloc rejectHttpBloc=MyBloc();
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>().post(RelatedCompanyGetListEvent(httpBloc,''), context);
    });

    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels > 0) {
          _hideFabAnimController.reverse();
        }
      } else {
        _hideFabAnimController.forward();
      }
    });

    rejectHttpBloc.stream.listen((event) async{
      if (event == true) {
        await locator<Web>().post(
            RelatedCompanyGetListEvent(httpBloc, ''),
            context);


      }
    });
  }

  @override
  void dispose() {
   // httpBloc.dispose();
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    rejectHttpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: ColorPalette.Background,
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: StreamBuilder(
              stream: httpBloc.stream,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if ((snapshot.data as List<Company>).length > 0) {
                    return ScaleTransition(
                        scale: _hideFabAnimController,
                        child:FloatingActionButton(
                        backgroundColor: ColorPalette.Yellow1,
                        onPressed: () {
                          if (locator<Constants>()
                              .getSite_id() !=
                              '' && locator<Constants>().hasAccess(context,AccessEnum.addRelatedCompany, null,null))
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  NewRelatedCompanyPageWidget( )));
                        },
                        tooltip: 'add',
                        child: Icon(
                          Icons.add,
                          color: ColorPalette.White1,
                        )));
                  } else {
                    return Container();
                  }
                } else
                  return Container();
              }),
          body: SafeArea(
            child: Column(
              children: [
                BarTopAppBarWithSearchWidget(  onSearch: (search) {
                  locator<Web>()
                      .post(RelatedCompanyGetListEvent(httpBloc,  search), context);
                },),
                Expanded(
                  child: FractionallySizedBox(
                    //alignment: Alignment.centerRight,
                    widthFactor: 1, heightFactor: 1,

                    child: Container(
                      padding: EdgeInsets.only(right: 16, left: 16, top: 16),
                      color: ColorPalette.Background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MyText(
                            text: Strings.RelatedCompanyPageWidget_title,
                            textAlign: TextAlign.right,
                            color: ColorPalette.Black1,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          StreamBuilder(
                              stream: httpBloc.stream,
                              builder:
                                  (context, AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  List<Company> companies =
                                      snapshot.data as List<Company>;

                                  if (companies.length > 0) {
                                    return Expanded(

                                          child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount: companies.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return getListItem(
                                                    companies[index]);
                                              }),
                                    );
                                  } else {
                                    return Expanded(
                                        child: FractionallySizedBox(
                                            //alignment: Alignment.centerRight,
                                            widthFactor: 1,
                                            heightFactor: 1,
                                            child: Container(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/vectors/Icons/TeamworkGrayScale.svg',
                                                  width: 56,
                                                  height: 56,
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                MyText(
                                                  text: Strings
                                                      .RelatedCompanyPageWidget_no_company,
                                                  textAlign: TextAlign.center,
                                                  color: ColorPalette.Gray2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                FloatingActionButton(
                                                    backgroundColor:
                                                        ColorPalette.Yellow1,
                                                    onPressed: () {
                                                      if (locator<Constants>()
                                                          .getSite_id() !=
                                                          '' && locator<Constants>().hasAccess(context,AccessEnum.addRelatedCompany, null,null))
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  NewRelatedCompanyPageWidget( )));
                                                    },
                                                    tooltip: 'add',
                                                    child: Icon(
                                                      Icons.add,
                                                      color:
                                                          ColorPalette.White1,
                                                    ))
                                              ],
                                            ))));
                                  }
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget getListItem(Company item) {
    return Column(
      children: [
        /* MyText(
          text: 'زیرمجموعه پیمانکار',
          textAlign: TextAlign.right,
          color: ColorPalette.Black1,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),*/
        /* SizedBox(
          height: 16,
        ),*/
        Stack(
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.White1,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                            color: ColorPalette.Gray1.withOpacity(0.25),
                            offset: Offset(0, 0),
                            blurRadius: 4)
                      ],
                      border: Border.all(
                        color: ColorPalette.White1,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerRight,
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: item.site_logo != ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: LoadImage.load(
                                      url: item.site_logo,
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.fitHeight))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(24.0),
                                  child: Center(
                                      child: SvgPicture.asset(
                                          'assets/vectors/Icons/image.svg',
                                          width: 24,
                                          height: 24))),
                        ),
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        MyText(
                                          text: item.organization_name,
                                          textAlign: TextAlign.right,
                                          color: ColorPalette.Black1,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        SizedBox(height: 4),
                                        MyText(
                                          text: item.project_name,
                                          textAlign: TextAlign.right,
                                          color: ColorPalette.Gray2,
                                          fontSize: 11,
                                          fontWeight: FontWeight.normal,
                                        )
                                      ],
                                    ),
                                  ])),
                        ),
                        item.getStakeHolderLabel(),
                        item.getRequestLabel(onApprove: (){
                          if (locator<Constants>()
                              .getSite_id() !=
                              '' && locator<Constants>().hasAccess(context,AccessEnum.approveButtons, null,null))
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              //enableDrag: false,//enable drag false only for map
                              builder: (context) {
                                return BottomSheetWidget(
                                  title: Strings
                                      .BottomSheetWidget__ApproveRelatedCompany_title,
                                  content: ApproveRelatedCompanyWidget(company: item,),
                                );
                              });
                        },onReject: (){
                          if (locator<Constants>()
                              .getSite_id() !=
                              '' && locator<Constants>().hasAccess(context,AccessEnum.approveButtons, null,null))
                          locator<Web>().post(
                              RelatedCompanyRemoveRequestEvent(
                                  rejectHttpBloc, item),
                              context);
                        })
                      ],
                    ))),
            Positioned.fill(
                child:item.stake_holder_status==stakeHolderStatus.Pending?Container(): Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    onTap: () {}),
              ),
            ))
          ],
        )
      ],
    );
  }
}
