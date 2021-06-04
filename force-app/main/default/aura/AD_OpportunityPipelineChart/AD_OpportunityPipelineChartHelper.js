({
  generateOpportunityPipelineChartHelper: function (component, response) {
    var boolChartLabelInitiated = false;
    var intYposition = 0;
    var conFigColor = "black";
    console.log(response);
    var opportunitychartData = {
      labels: response.lstOpportunityStage,
      datasets: [
        {
          //label:chartLabel,
          data: response.lstOpportunityPipelineAmountByStage,
          backgroundColor: "#36A2EB",
          borderColor: "rgba(82, 359, 222, 1)", //Bar background color
          fill: false,
          pointBackgroundColor: "#FFFFFF",
          pointBorderWidth: 4,
          pointHoverRadius: 5,
          pointRadius: 3,
          bezierCurve: true,
          pointHitRadius: 10
        }
      ]
    };

    //Get the context of the canvas element we want to select
    var oppChartDiv = component.find("opportunityChartDiv");
    oppChartDiv.set("v.body", []);
    var opportunityChartDivCtx = oppChartDiv.getElement();
    var opportunityBarChart = new Chart(opportunityChartDivCtx, {
      type: "bar",
      data: opportunitychartData,
      options: {
        legend: {
          position: "bottom",
          display: false
        },
        events: [],
        tooltips: {
          enabled: false
        },

        responsive: true,
        maintainAspectRatio: false,
        scales: {
          xAxes: [
            {
              ticks: {
                autoSkip: false,
                maxRotation: 45,
                minRotation: 45,
                mirror: true
              },
              gridLines: {
                display: false
              }
            }
          ],
          yAxes: [
            {
              ticks: {
                beginAtZero: true
                //max: response.intMaxCount, //Uncomment for manual max
                //stepSize: response.intChartInterval, //Uncomment for manual step
              },
              scaleLabel: {
                display: true,
                labelString: "Amount"
              }
            }
          ]
        },
        title: {
          display: true,
          //text: '(Values are in million)',
          position: "top"
        },

        animation: {
          onComplete: function () {
            var ctx = this.chart.ctx;

            //Check if chart label has already initialized
            if (boolChartLabelInitiated == false) {
              conFigColor = ctx.fillStyle;
            }

            this.config.data.datasets.forEach(function (dataset) {
              ctx.fillStyle = conFigColor;
              ctx.fontStyle = "bold";
              ctx.textAlign = "center";
              for (
                var intIndex = 0;
                intIndex < dataset.data.length;
                intIndex++
              ) {
                if (
                  dataset.hidden === true &&
                  dataset._meta[Object.keys(dataset._meta)[0]].hidden !== false
                ) {
                  continue;
                }
                var model =
                  dataset._meta[Object.keys(dataset._meta)[0]].data[intIndex]
                    ._model;

                //To handle the case of tool tip, because tooltip takes the bar number label bit lower.
                if (dataset.data[intIndex] !== null) {
                  if (boolChartLabelInitiated == false) {
                    intYposition = model.y - 5;
                  } else {
                    intYposition = model.y - 15;
                  }
                  ctx.fillText(
                    dataset.data[intIndex].toFixed(2),
                    model.x - 1,
                    intYposition
                  );
                }
              }
            });

            //Initialize the veriable to tell that chart has been initialized once.
            boolChartLabelInitiated = true;
          }
        }
      }
    });
  }
});
