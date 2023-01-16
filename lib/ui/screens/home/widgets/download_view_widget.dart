import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DownloadViewWidget extends StatelessWidget {
  final int progressValue;
  final double percentValue;
  const DownloadViewWidget(
      {super.key, required this.progressValue, required this.percentValue});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Column(
          children: [
            LinearPercentIndicator(
              barRadius: const Radius.circular(100),
              percent: percentValue,
              progressColor: const Color(0xff7c2ae8),
              backgroundColor: Colors.grey.shade100,
              trailing: Text(
                '$progressValue %',
                style: Theme.of(context).textTheme.headline2!.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff7c2ae8)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Descargando a tu galería',
              style: Theme.of(context).textTheme.headline2!.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2b0d54)),
            )
          ],
        ),
      ),
    );
  }
}
