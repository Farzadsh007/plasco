import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/bars/BarTopAppBarWithSearchWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/RelatedCompany.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class NewRelatedCompanyPageWidget extends StatefulWidget {


  const NewRelatedCompanyPageWidget({Key key }) : super(key: key);
  @override
  _NewRelatedCompanyPageWidgetState createState() =>
      _NewRelatedCompanyPageWidgetState( );
}

class _NewRelatedCompanyPageWidgetState
    extends State<NewRelatedCompanyPageWidget> {
  _NewRelatedCompanyPageWidgetState( );

  MyBloc httpBloc = MyBloc();

  Future<bool> _willPopCallback() async {
    bool ret = true;


    return ret;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>().post(RelatedCompanyGetHolderListEvent(httpBloc,''), context);
    });
  }

  @override
  void dispose() {
    httpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body: SafeArea(
            child: Column(
              children: [
                BarTopAppBarWithSearchWidget(),
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
                            text: Strings.RelatedCompanyPageWidget_new_title,
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
                                      child: SingleChildScrollView(
                                          child: ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: companies.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return getListItem(
                                                    companies[index]);
                                              })),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              }),
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
    return Stack(
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
                          ? LoadImage.load(
                              url: item.site_logo,
                              height: 24,
                              width: 24,
                              fit: BoxFit.fitHeight)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    item.getStakeHolderLabel()
                  ],
                ))),
        Positioned.fill(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                onTap: () {
                  if(item.canSendStackHolderRegistration(context)){
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        //enableDrag: false,//enable drag false only for map
                        builder: (context) {
                          return BottomSheetWidget(
                            title: Strings.BottomSheetWidgetRelatedCompany_title,
                            content: RelatedCompanyWidget(company: item, ),
                          );
                        });
                  }

                }),
          ),
        ))
      ],
    );
  }
}
