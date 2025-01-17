import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/views/company/CompanyPageWidget.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../LoadImage.dart';
import '../../inputs/MyText.dart';

class ChooseCompanyWidget extends StatefulWidget {
  ChooseCompanyWidget({Key key, this.selectedItemBloc, this.selected})
      : super(key: key);

  final MyBloc selectedItemBloc;
  final DropDownItem selected;

  @override
  _ChooseCompanyWidgetState createState() =>
      _ChooseCompanyWidgetState(this.selectedItemBloc, this.selected);
}

class _ChooseCompanyWidgetState extends State<ChooseCompanyWidget> {
  _ChooseCompanyWidgetState(this.selectedItemBloc, this.selected);

  MyBloc selectedItemBloc;
  DropDownItem selected;
  MyBloc httpBloc = MyBloc();
  MyBloc updateMemberShipBloc = MyBloc();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      locator<Web>().post(CompanyGetMyListEvent(httpBloc), context);
    });
    updateMemberShipBloc.stream.listen((event) {
      DropDownItem item = event;
      // setState(() {
      selected = item;
      locator<Constants>().setSite_id(item.id.toString());
      locator<Constants>().setSite_name(item.value.toString());
      if (selectedItemBloc != null) selectedItemBloc.add(item);
      Navigator.pop(context);
      // });
    });
  }

  @override
  void dispose() {
    httpBloc.dispose();
    updateMemberShipBloc.dispose();
    super.dispose();
  }

  Widget getListItem(Company item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
              onTap: () {
                locator<Web>().post(
                    AuthUpdateMemberShipEvent(updateMemberShipBloc,
                        DropDownItem(item.id, item.organization_name, item)),
                    context);
              },
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
                  IgnorePointer(
                      child: Radio(
                    activeColor: ColorPalette.Yellow1,
                    value: DropDownItem(item.id, item.organization_name, null),
                    groupValue: selected,
                    onChanged: (val) {},
                  ))
                ],
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
            stream: httpBloc.stream,
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                List<Company> list = (snapshot.data as List<Company>);
                if (list.length > 0) {
                  return Container(
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
                              })));
                } else {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: MyText(
                      text: Strings
                          .BottomSheetWidget_ChooseCompany_not_registered,
                      textAlign: TextAlign.right,
                      color: ColorPalette.Black2,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  );
                }
              } else
                return Container();
            }),
        SizedBox(
          height: 24,
        ),
        Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CompanyPageWidget()));
                },
                child: Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.add_circle_outline_sharp,
                          color: ColorPalette.Green1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: MyText(
                            text: Strings.BottomSheetWidget_Account_signIn,
                            textAlign: TextAlign.right,
                            color: ColorPalette.Black2,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      ],
                    ))))
      ],
    );
  }
}
