#import "LufaxRootViewController.h"
#import "JVUtility.h"
#import "JVLocalModel.h"

@interface LufaxRootViewController ()

{
    NSString        *   backButtonCB;
    NSString        *   taskCallBack;
    NSString        *    sessionId;
}

@end

@implementation LufaxRootViewController

#pragma mark - Init
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor=COLOR_HEX(LuStyle_COLOR_WEAK2);
    
//    [self.model rz_addTarget:self action:@selector(naviBarChanged:)  forKeyPathChange:@"naviBar"];
//    [self.model rz_addTarget:self action:@selector(leftViewChanged:)  forKeyPathChange:@"leftNaviItem"];
//    [self.model rz_addTarget:self action:@selector(rightViewChanged:)  forKeyPathChange:@"rightNaviItem"];
//    [self.model rz_addTarget:self action:@selector(rightMenuChanged:)  forKeyPathChange:@"rightMenu"];
//    [self.model rz_addTarget:self action:@selector(centerViewChanged:)  forKeyPathChange:@"centerNaviItem"];
//    [self.model rz_addTarget:self action:@selector(bottomViewChanged:)  forKeyPathChange:@"bottomView"];
//    [self.model rz_addTarget:self action:@selector(pageChange:)  forKeyPathChange:@"pageDic"];
}



-(Class)modelClass{
    return [LufaxRootVCModel class];
}


//ReactJS--单页面切换时隐藏问题
- (void)resetRefreshViewWithRefreshType:(NSString *)refreshType {
    self.model.refreshType = refreshType;
    BOOL hidenRefresh = NO;
    if ([refreshType isEqualToString:@"0"]) {
        hidenRefresh = YES;
    } else if ([refreshType isEqualToString:@"1"]) {
        if (!self.refreshView) {
            [self initRefreshView];
        }
        self.refreshView.model.refreshType = @"1";
    } else if ([refreshType isEqualToString:@"3"]) {
        if (!self.refreshView) {
            [self initRefreshView];
        }
        self.refreshView.model.refreshType = @"3";
    }
    [self.refreshView hidenRefresh:hidenRefresh refreshType:refreshType];
}


#define HTML_START_FRAGMENT @"<!DOCTYPE html><html><head><title></title><meta name=viewport content=\"width=device-width, initial-scale=1,maximum-scale=1.0,user-scalable=no\"><meta http-equiv=Content-Type content=\"text/html; charset=utf-8\"></head><body><div id=body_wrapper class=device_classify></div></body>"

#define HTML_END_FRAGMENT @"</html>"

#define HTML_RETRY_START_FRAGMENT @"<!DOCTYPE html><html><head><title></title><meta name=viewport content=\"width=device-width, initial-scale=1,maximum-scale=1.0,user-scalable=no\"><meta http-equiv=Content-Type content=\"text/html; charset=utf-8\"></head><body><div id=\"body_wrapper\" class=\"device_classify\" style=\"text-align:center\"><img width=\"135.5px\" height=\"125.5px\" style=\"margin-top:65px;\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQ8AAAD/CAYAAADvylOTAAAABGdBTUEAALGPC/xhBQAAKcZJREFUeAHtXWmwHNdVPj1vX/Te02JJ1i5ZsmVZincR2zFZXEDIAiSkigBFhYIiIeRHQhUUxfKDggA/IJCqUFChoEgq6w+TkIVgQhzb2I6XOI7tWJZtSZYsW9aut+/vTXO+O6/n3enpmemenr5zu/scezT9er3nu+d8c++55952XBYSyTQCRa7hpeXSZ5m/8XexWPosr2zDCvh/9Q++datwHCL+X/2Db/xdKBB1rHxju8DbHR1EnSsf/C2SbQQ6s61evrRbZGJYXFr9gDA8soiDhE4kYe+jk0kXW1n5w+Qikg0EHGl5pLMiQQzzi0QLKx8QRzNOblp7tFq6mEC6u0qfHv5Ga0UkfQgIeaSkzkAWcwulDwhjmbsdWZEO7vaATHq7Sx8hk3TUrJCHpfWEVsQck8TcfIkwQB55EZCHIpIe/mZSQWtFxD4EhDwsqhMQxiy3LmbmSoSRhm5I0vCBOEAk/b1EffwtRJI04uHvL+QRHqtEzsTIxiy3LmaZMEAcQhi1YQZxgED6QCTcKpEGSW2sTBwR8jCBcsAzMCoyzYSBD4ZNRaIhgOHhASYRfDCSI2IeASEPg5ijlYEuyfRsaaTE4KMz/SiM2Az0lbo20hoxV9VCHgawRldkigljciZboyQGoIv0CIzarOknGmQikdhIJOiaOlnIoynYwl2ETM4pJoxJJg7pmoTDrBVnoUuzhglkkIlEMl1bgWjwPYQ8gnGJtRekgVYGWhtCGrGgjHUxSAStELRGhERiQRl4sZBHICzN7UTilkcaMmrSHIZJXIUujEci6NqItAYBIY8W4IiWxvhUaeRESKMFgCZ0C5AIRmeGB6Ul0gqIhTxiooiuyfi0dE9iwmj0cnRnhgdKrRGjD87Yw4Q8mqzQBc7TGJ0sTUxr8hZyWZsRwHyatWt4Xo3kiTRVE0IeEWFDt2RMuigRUbP3dK8rM8JdGRnejVZPQh4R8EI2KGIbWZrRGkH9TJ+KQCpiIYiJiIRDQMgjBE5YKwNdlHmeeyKSbQR6eO4MujJYc0SkPgJCHvXxUUOvCIjKKEoDoDJ0GN0XBFSRHyJSGwEhjxrYYPj1ykRpxmuNU2R3xhHAzN11QzKsW6uahTwCkMFKXZeZOPK0AE8ADLKLEcDCROuZQDAyI1KJgJBHJR7STfHhIX+WRmGkG1NtCUIeK5hIN6XaOGRPJQLSjanEQ8iD8cAq5Oim4DUFIoJAPQTwbhp0Y7CGSN4l9+SBiWwympJ3N4imv4zGlPDKNXkgUxTkISIINIMAhnKRmZpXyS15YBgWGaMigkAcBJCRiuHcPEruyIPTN+jyuORv5NHYk9IZgdT1w/lbzT1X5IERlUtjsvhwUk6U5/sigLphJF8JZbkhD0xmu8jEgVceiAgCSSCAV0BcxQSSl9XKckEemNgG4pCh2CRcRu6pI4CMVLRA8jCxLvPkgUV7QByyELFu4rKdJAJYqQwtkKwvMpTp5WC9FocQR5KuIvf2IwB7U13kjCcdZpY8vBiHEIfftOVvEwh4BJLlhaMySR4YVZEYhwkXkWfUQwAxNtVlRn5ABiVz5IF6wnCsjKpk0FpTqBLsEPaYRf7IHHkgAQwT3UQEAVsQUBMv2S6zJpkiD1n5K2vmmR19ZudLK9NlRyNOiMuKMt7rELKij+iRPQQwlwp2mhXJBHlgZqzMjs2KSWZbjyzZaurflYX+JNbjMC0Yihsdm6fJiUWanlni1zIs0/KSy6usZzE0Zhrd5J7n8GIcHZ0O9XR30EB/Jw0NddHISA8hscuUwF6xJmraFxRKdYYphmTPXTGbdj4/X6Q3zs7Q5ctznLUqRGHK4ZJ8TqHg0Pr1vbTl6n7q6THDIliRbPO6dE+kSzV5XDI4tR4tjTNnpunc+VlpXSTpyW28N1olmzf10datA0ZaIpjKv4Gn8qdVUkse6DuaCj7NcWvj2PFxmuXuiUj2Eejj7sy+vcPUa6AVgpXI0vpyqVSSB96rcgGJNwZ6DTMzy/TSy2O0uMhND58M9HfQtqt7aOOGbhpa08H96IK8LNmHkW1/wmbmF4o0MblMFy4t0Otn5zlmVT0JpaurQNddO0L9XMdJCtZD3YhJdClcUDl15IEww3mOc5h4IRNaHEePjlYRR39fBx3aP0DbtnC7UyT1CIBAfnJ0mmZmK0kEBHL99WsTb4FgGv+mFMY/UkcepuIciHEcYeLwd1W2bOqh229ew28S458MkcwgsLTs0g9/PElvnOdsLk3QhbmBCSTp0Zg0xj/MhJa1yoiziTgHMvVMCIKjfuLYu7uP7rhtSIjDRAUYfgZ+DFC3e3dXvt0aNgBbSFpg12nLVUoNeWBtDlP5HBiOxaiKLmhx3Hggx+vs62BkePvGAwOEutYFtgCbSFpg37DztEhqyGN00kyAFBWHPA492QsxDnRVRPKBAOoade4JbAE2kbQgmAs7T4ukgjwwJ2B+wQykyxyRRQKYLoeuH5Cuig5IxrfRhUGd6wKbgG0kLbDztLxPyHryABuPG5xMND62UJE56g3HJm00cn+7EMAQPOreE2QTwzZMCOwddm+7WE8eSAQzuZTbOM9V0WW7DMfqcORq21/3fttICgzYu6kEyDg6WE0eWPncdBNuxpdFetX67jj4Jnotcl2w+NGZS6UPtk3kvySqlEU399e93zaSLCrsHvZvs1g9q9ZkkNSrpPn5ynA3MkdtFJDE+dHKV0rM8HDfHDecNq0ljtFUlxq/ZjBK5LDYIMidwLtebX1ZtL/u/baRJIZe8BR1aatY2/KY4pFSpKGblmVOFtIFKec2CvrFQSSAfUExIhAH8giCrmmXfiiLyTlKUfX0173fNqLeL+r5sH/4ga1ipWcgqG0qp8NfMfoQLY5h7oGNghZGLQk6Zrr7V6tsQfttLZu/7v22EaRLq/fBDwwM8jRVbCvJo9avalMaykWCQIoRqNWStEEl68gDkWZbf4lsqDCvDL11ZmEGHUNswVaxuWw2YAZ/MDniGFZn68gDfeA0jHGHBTip84Y5Uz5oshb24ZhfvHUjgq7xn2vqb5QFa1nYGjA1hUOj58AfbJz3YtVoC/p2NgeIGlWyyeNqGjdH4tHF82IcaHGAOIJGWlA2OKk4qslaat2z4BdDnPTKKyZaI1aRh7Q6otkFSGJ9ipexi6Ztvs/2Wh/DlVnzbQXFmm6LtDraagfy8BQggNaHTSMv1pDHlGU5CCmwJSlizhDAyAv8xBaxgjxUk8ziZBhbKkvKIQhMsp/YMqBgBXmo5hizqoggIAjUR0C1Piz5oW07eSAZ3MZhqPpVKEcFgfYhoAYW2vf48pPbTh4zlibAlBGSDUHAMgSQMAa/abe0fah22pImWCsrYnJqmU6enqPz/F4QLOe/xO+wFTGPQCe/kxbLCW7i9+rs3tFLawYDphqbL1ZLngi/aXdmblvJY5HXK8CLqrMiCGQ9+8IUvfLqXMUaqFnRL216gLQnJpfU5/ipWdqzs1ctYu2f8JY2vVBe+A38p6uNHtzGR2drDguI45Enx9VbyPDi5Gt29dGOLb38JrlOwkuNRcwjsMxrnoA8Tp+Zo1e4JXiCCQStwrccHrZ2tnQUlDDnpZ0Zw20jDzTkszQBDi0OvL6wr7eD7rp9mIaHhDGiOEIS54K014508meQdm3vo0d/WCJ31NVNNwRMAEqiEAneE/6D6QjtylhvW8AUL7nBsFMWBL9m6KqgxSHEYWeNgsxRN6gj1BXqLO0C/zH1ErQgrNpGHjZEi4MAaWYfgqNYKGYPB+WkxdEMgmauQd2gjlBXqLMsyGwb1WgLeSA+MGdmFXsj9oFRFciOrRYvmmEECfsf4tWRV2f2l7h+CWfZ9OBP7ZC2kAeaWu1SOAmQvberIzgqYjcCa1YWtJ6dzUafGX7Urq5LW8gDq3xnSbw8DhlVsb9W8TY4yOJSNsgDurTLn4yTR9a6LKg8EUGgnQggBNCOlrxx8sCqV+1QtJ2VK88WBJJEQP0gtyHZ0jx5ZKzLkqRRyL0FgbAIzLXBr8yTR4ZGWcJWrJwnCCSNQDtGL42SB16RKO9STdqM5P55RKAdvmWUPNrBjnk0JNE5nwiY9i8hj3zamWidQQQyTR7teHF1Bm1EVBIEAhEw7V/GWh7ok9n4yrzAWpCdgkAKEYB/mYwpGiOPLC36k0K7kiLnBAGTfmaMPEw3qXJiK6KmIFCBgEk/E/KogF7+EATSjUAmyWMx/WuvpNuqpPS5QMCknxlpeUAhmc+SC9sVJduMAPzMFIGYIQ9e5VlEEBAEzCCAVdVNiJCHCZTlGYKAQQSEPAyCLY8SBLKEQKbIw2TiSpaMQHQRBJpBwJS/Gem24OU7IoKAIGAGAVP+ljh54N0SxTat7mymquQpgoBdCMDfTLwTKXHyyNA6s3ZZiJRGEKiDgAm/S548pMtSp4rlkCCQDAIm4h6Jk4ep/lcyVSB3FQTSiYAJv0ucPCTekU7jk1KnGwETfpc8eWTn3TrptiYpfa4QyETA1IQSubIKUVYQCIGACb9LvOWxLMO0IapaThEEWouACb9LnDxMMGBrYZe7CQLpR8CE3yVOHjIVP/2GKBqkDwETfpc8eaQPdymxIJB6BExECxInDzKhReqrWhQQBFqMgAG/S5w8DOjQYtTldoJA+hEw4XfJk4cJLdJf16KBINBSBDIR82gpInIzQUAQsAaBxFse1mgqBREEBIGWItDZ0rsF3MxxZOX0AFjs2DU9TnTqJ+Sef5Xo0uvk8oemJ4jmZ4gWZktl7O4j6uknGhgiZ8M2Iv44m3YS7TrE+4bt0ENKUYUA/C5pSZ48ktZA7h8NgTeOkfvMA+Qef5ro/Cl+JUaDoNTSItEME8roOXJff7n8LAfWuWkXOXtvIeemtxNt2Vc+JhvtR8AAd1Di5EEmtGh/XdldAm5FuE9+h9wf/U+pldGC0irSOXeSXP7QI/+hWiPOrT9HzuF3EaG1ItJeBAz4XeLkYUCH9laSzU+fmyb30a+T+4P/JHd2MtGSouvjfudfyHngK+Tc+Uvk3PU+ot6BRJ8pN6+NgAm/S548TGhRG8PcHnGf/i65//2v5CKuUUOcQgd3N/aSs+sg0VXbyeEPjVxVinF4rQfEPhADGbtI7sXXiPjjnnqe6I3j5Barl4kDSbn3f4GcJ75Fzjt/m5xbfrbG02V3kghkIuZRkPGcJG2k+t5XzlLx3r9lBz9SfYz3OB38e3HdYSrcfA8RxytUMDTwzJWdfWuI8BnZRIpkcA8cAqEce5qKz9xP9NKT5C5XvqbMnRoj995PkfPUfVT4wB8SrbsaV4kYQsCE3yXe8uiQlochc+FRrecfJvdr/0Aud1f84vTzaAl3JZw3v7dEBv4Tov6NEZiDb6ECfwitjce/VeoiIbiqCUis+I8fI+f9v0/Owbu1I7KZJAIm/C5x8jDBgElWQlrujXhDkQOXfnG6e8l526+qOATxdiLCLRPn7b/G5PT+Unzlwa+QuzBXfhTIzP3yJ6lw9wfI+fnfKe+XjeQQMOF3Qh7J1Z+ZO3Pcwb3377j78P2q5znX30GF9/4edzk2Vh1LZIciqg/y0O07qPitfyL36GMVjyk+fC8VJq+Q84E/IEK8RSQxBLJBHtJtScxAiImj+IU/J5djDro4nd3kvPsj5PzUe/Td5raZrAq/weV64tvk/tdnyV1aKD8bJOfMTqnjQiBlWFq+UTDgd4mHMzvkB6blhuHdEC2OKuIYWk+Fj366fcThFY6/QV6qLFwmXVBmlF0kOQRM+F3i5NEp5JGIhagYh6+rgvTxwu9+mujqaxJ5ZlM35bKgTCq1XbsBWiDQQSQZBEz4XfLkkfgTkgHf5rtiVMUfHFXE8ZG/NxffiAIQujFctioC4QAvdBFpPQKZIA8Ebkz0v1oPv6V35DwODMfq4qCr8lt/Y/dENZ5EhzKirLooXVgnkdYhAH8z4XOJj7YAEvS/ipU5RK1DKmd3UglgWh4HgqOFD/1l8y2OxXmeWfs8uSef43kvp3h27RmeWctZqfqsWsye3bCV56/wRLjdb+IZtZyR2tUTHXm0QLisxX/+RDmIimFc6FT4MLeaRFqCgIl4BwpqhDzQhFoU8ohtGCrl3Jc5ilGVpmIcx57iiXKcws7Dqe7i6mhIVSG9WbVISz/6ONGDXyWni0dzeBjYuZVTz/fdVnVJ3R0cA0GZ3W98pnwaEsmgm6SylyGJtWGiy4ICGiGPLn7KLP/AicRAAIlWPFdFF+XAUYdjjzxKxe9/kdyzr+i3irQNsnGfe4iIPw4Cou/4daIb7gp9D4zCOC8zeWl5IO59/0bOAb6HTKYLjWOtE+FvJsRIONOUMnEBcy1+r66aHatNckPmqEoAC6s05rz8+5/Q8pf+IhZx+B/nnj2h7ol7U4TYBcoOHTxRc2F4BrBIfARM+ZsRjjKlTFzYT5xMdtp60+XDehw8rV4XpJyHzRxFK8H9+qfJxWS2AHF40pqz71YVy3A27ijdV59VO3aB3AunS7ERdHeunKu6i3vsR1T8DBPC+z5BzpveWnW8agfHP5y3fZDc736ufAg6Onf/sqwHUkakuQ1T/maGPDjmYftyhGfemKErV1bnYzRXbclcpRby0dbjUJPceM2MMOL+7+ep+MCXq07FdHzn0N3k3PGLRDsOVB0v71iZVYvuCd349tKM2tMvkPvYN8j9CU/E06blg5zcr/41FTjw6vzMh8q3qLXh3MkT9R75Grkrk+nUdH5etMh5CxOIpQI72bqFJwVaKvCzLvY3E2Kk2wJFTCnUDGiXL8/TmTPVM1GbuVcS12AFMF3UQjtak18/pm+73/zHYOLgqfiFj3+WnF/54/rEod9M32aywbXqHpjW7xOQFZ7dUDAXBosGaeLXVTtkxSbsBPZiq5j0s1DkgWUuT56eoxePz9DpM/O0sMg7Ikp3V8QLDJ0+MbFIJ09Z2l0BBlhzFAsUrwjW41DT6r0dNb5Vi4OnyeuCUZLC+z5eygnBwj9xhe+B3A3cE/fWpYgp+tzqaSTQRa0xsnKi0pV1tllgL7AbG6UZP4M/w6/h3/DzRsvaenqH6rbgpi+8vPrL3MGLBeze3ksH9w+qHA7vZvW+lVIrC3LXO8/ksenpJTp2bIKKxehkaKqcWKy4QnghH7U4T8XOyj8Q4/B3VZzBEc6x+CTR1tYvVOzc/i5yeAHk4uf/jBD49ARlKCA3pF4MBN0i6PTCD7zL1ALNuJ+tAnuB3ezfP0wDA6FcyJgqUchjmReCe/7FKTr52hwtL6/6wNx8ka7f17hrFqrlce5iZR4AHnT81Czd/8goTU5xCUJIj2Utj9m5ZXrp5XFaLupDLNxhtEzUKudamdQKYNrfVZvIQOXgqC6KOD78qUSIo/wcJqUCPwPP0kWVpcEoTOGme/RLSiu7V+yx7w/YDewHdmSThPUz+C38F36sEwd08ft7Lf1CkUdnjWWJJqeW6KHHxmh8ojGASFzpCPW0WkVt3f6FBa74l8ZpaUknDu7+b7dswV4MzSLrc0XUmqMBMQbvOL6LnHylj6qorgpaHHjnStKCiXn8LL0Lg7KgTHVlH7++QV/fAzprw9J1r23jQdgP7Aj2ZIPAv8IkiMFf4bfw3yCp5e/+c0O580B/7fDtPAP30BOjdGUsuCD6A6M0qfTrWrk9z02yF18c4wqvJLytWwZo82bLXhmAFzLpHVB0ObD8Xy3hBDAMmerivOejybY49Idhm8uonqntV2XistUU6LRlb/mw0pl1t1FgJ7rAjmBPsKt2Sxj/gp/CX+G3taSev+vXhCKPTRvq9zkWF1x64NFR+vb3LtMzR6ZoZja4YL2VMTW9HEa20Zc7yhU9N19JHBs39tHWrXWc0kjpqh+iB0px1Nl5Q/VJ2p7i97+k/cXncysF8QjTomIgvhaSv2z+MnmLK3v7/bp7+9v9DTuBvegCeyrZVbDd6+cmuV3Lv+CP8Ev4J/wU/lpPGvm7d21D8kAkdoljHGGWcgf7nuA+1H0PXKZXXq3OmailnFeYJL/nuG969Gh1i2Pdul7atXMwyUc3f2+8/lEXJHDVEiRvcbanJ+gGRMpA9S5s0bfKINW6IqpsXMaa4tfNr3vNC80fgL3AbnRBCwT2BTtrlwT514lTc8of4ZdhWkfwc/h7mBHVwFDx9EyRXn19js5eWOB4xlJl0zkEMmhp//j5SSryxt5dqyyN/hg+S4bxnZnl4OhLY7S4WPnLsH59L12zh6P9lop6d6xWNv96GNohNclN/9s59NPqXSz6PqPbPIyLJDT32QfLj8VEPKfGRDq/btDdvvB1WRXae80aOsEFvHx59UdycbHUArnuuhHq76vd1V+9S+u2PN/S74hg6LPc4ogi8N2nnp3kxsIUDQ910tUbu2nntl4a6K9uZ1SQhzd0c4JbDRV97ShP18599sg0bVjbRSPDq48BO04ZHLIdH1+k48cnfKMq7Fcbemn3bnuJQ8GIl07rghcyBQlPq9cnmeEU545fCDrT6D6VvaqTB0+Ec7AEQNB0fr9uft2Nljzcw/DDg3UzLl7SCYS7xi+M0d69QzQ8XL+7H+4p4c7ytzrGxpeYOFbTK8LdZfUs+P8Y+w4+SNW4Zmd1akaZTpaWXHr4iTE1dNMK4igVw6XnjlYq0NvEMhCrKkXbunBhLmA4llSf1XrigKr+uSi1gqVYj0ObVo+5KnVTzqPB2PzZyERdt7l8vSoj3jYXJH7d/LoHXWPBPtiRPwbiDePC/kyJ369Kflc/thG2bOADtGLAD+AJT8rkgabK5dHWZ81dvLxQEUDtZTIOEz/xCtjMN5per702TadeReboqrK419Wb++2NcfiV9Rbk8fZ7k9W8v1e+sZCPLmqSm76jjdv+boq/rOWi+XXz614+0b4NxEBgV5XiKvuDHcIekxT4E/zKEwRI4XetFvADeMITRR7nOLZx5lxy+foXLq0qohRNcNQFY+4YOjt7zj+D1KGdO9fQdttyObyaCPoeWE24coa5y4JXRQaIWgFM34+VvmwRX1mqyuqVE2n30NETTXdvl83fsCvYF/80VhQTdlhKDaiMt1WcFPMPdFn0H2Td32Leuupy8AT4AqLI4/jJZIMQR4/NcLBylX77KwPVVQVsdsfY2AI9fwRZr5UtqAJ3TK/dN0SbNib04GYL3OC6Aqa3s0Phg+2agqUDNVHT6rW/27lZVRZfWfWyhdZXv8iibdgX7Az2pgvsEXYJ+0xCdH+Cn8HfkhSPLzqRnX0pge6KXniMdjz0+BjdfXiEenoc6lthylY159APe51nO5b6mKskhTJ0d3eoCu3vD/7V1stp3fa1t1Hhj77YuFj+bExeK6MpufAquT+8j9PDOdGM1/BQgnU39t7K+SLv5GDRzui39ZfFX1b9jmH11a+xbHtkpJsOXD9CL/PcFz0REdmo2LeRCWbb1gHq7KwkmGbVQIsD/gSZn+e45ZNjHCZIdjgTfAHe6JzhcWl/bnupKK39F0O+Dz42SnfeNkxrBjuUwjMt6CldvjRPp1+fqhqGRelHhntoD0fEW1VRrUWkhXfzxwf88YNGj+I33Lvf4Te74Q1vFXN9+EKe0YuELecxXqgHywe+i9dMrdF9CnyMvyz+sgZelO6d+KE6eMNaeuWVSR6t0I3c5R+4WRodnacd2wZp/Yb4owfeDzHmqvzgqXGamk6WOFAz4AvwRqfJpfeg2PceHqV9u/to544BikMe4zwl+o0zM9xFqW4KOkzH27dZmG6elE8gPjB+Ud29Xmwk8PFMHMXP/Sm5J54JPOztBKm4j32THF5RrPCbfxWeQFZiGe5K+ShlsQxP/6jf+MG69tohOndull57HUHT1RYx8o1OnJygCxe7aQtnrA4PadHOiA9CSvrzL07TMQ49mJwdDt4oIJkFzpaUDA5UJstAwZdOzNDDj19R3YwFX+JWvXLgR/HylXk6cmRMJX0FEUdvbycd2D9i3zyVeorFPBYnVqBaHA2IQy8eSAbXRJE45YvyHBvPxXyp69keYZd+gf0ieRH2DLv2N/r85+t/w2/QTYcfwZ/8xOH3O/3auNvgC/BGJ97xMDzUwc2rxhPboj50kCfU3XP3WnruhWleZKQyKDvL/TI1lPqqw90YTiRb280Ad1B3V4G6uvnTWVBdEYyezM0t0SgHm8YnFvjdzqsMrpfH4SDV1qv76Wr+JMiF+iPt2W42VoAYB3dVogquUS/RDhsDabZ8UQtm6fmDg5106OBaOnt2hs7wx/WtHzM9s0gnTizye78d9sVuWstxE5BNN/yA/WGR4yWL7AcgDKS/j40urAwKBPvC7h199KYDA3T//43S1EzruzHgC/CGosNd2/vomfHV8dtW1EEfE8Gdh4eZnRy65RCPg2/qVqmy01XKuKrrEdSKCFuOkZEe7gYNcjC2nLYS9tJcn6eCo1F+7lbQUl0YDqyqd8bkGsHwyuMHbQuvfYopEa+enuKRFz0WUroPfhgRD8GnGcFs2BtvYF/jlHII/O/hx1u/5gj4AqLIY8+OXp7INksTk61pfWzd3EM3HRykXs2ZodCmDetUquvLr8y0IEjr0DpuraClYdtqTgrZFPyjRlWaLCeuTa6z22ShUnAZfuAwnItV7NASucKtCH8iY1Q1sLLftXv6af/efh4mXr16DYcM3vGWEXrm+amW5XENrekk8AVEkQdY8c23DKkFQurN818tVuUW+kBoymzaUJpEg9GUIIFiB67tpz2cJ//6WV50mD+XroCwgptfQffo6engZl0PbdzUy+QU/Jyg62RfAALecGzAoYa74lzb8ObZPwE/eJj/gun8F87Pcbd8nodao3QxHNqwrpO76j20jT/6D7WOHva/+dYhbt0vq8mu5zlhE4sB6QFc/fx62z3cjQJPeGGBchQHDv/WO0foyacnaIyHVRsJAiYbmSw2XdVFG9d3c/8s/O8QFMJsW3xmscbGsVIfDku6oW+3tMyRfeaTTo57oN+HD8Bey0OvfXUWJmpUZjkuCNiGAH4Ad/DIIz6z3KUf5aFdtEoQ68MH+SFw1k5eJgyxQIQDECO8fl839Wkt+0Z6wb8P7h+ggzTA9+UhY05fP39xkZCNGiYvZIRn2B5m4kBrxpMyeWBHqZmzll57Y16tonxlDMkgpVYBHH49z5AFYWzkxYFaFc0FAPv29NLYVLqyPz0AU/2NBC5tZfZIuviTvyJdLCcHIYAfxr5+/xyZ6jNHePmZvhgpIvihR2sFHwhSKC5cKhEJEsC8dT+QKbtupIt2czdl+5aecovDK1EFeWAnWG7H1h71wa8/0l2xr6srfMvCu3nY70GOv0xwRm0Tsbuwj5DzAhBA5mizK3bhWhHzCKDrD39ppaAhgA/CCRD4PHwfPu91UYKep4VXqg/jQrBUksSBp+I5a1oMSLU2ssePAFLOHT3C5j+hxt+4RqWr1zguu5NDAH5Sz6Fb8WT4O/y+0XPqkkcrChL2HoPcWmvCjsPeXs4LQoDzNFS+RtCxOvsi5XjUuY8cioaAanU07tVEu2mMs60hD0xEbHVzLAYuubkUc1Wca24KrS/OVfNbQl8hJ7YKAfiHb8Juq27d1H2sIQ+Ufg2zaqOmUlNaykW1EeC5J5irUuBlC+t1YXAM50Sa11L7qXIkIgKqa29RqwPFrwqYRtSppad7rY/JZJcjaGmZM3EzTF5778dUF6blU/IzAVD7lbCt1QFErCIPFAitDyyQrE1CxG4REwggBvJu7saYeJY8IzQCNrY6UHirui0oEF6ZNyApH4BCRBBQCMAfbHlVq14l1pEHCjfMSTAy8qJXk2znFQH4AfzBRrGSPBD7GK58JaiN2EmZBIHEEYAf2DTCoitsJXmggAgQhXlxr66MbAsCWUIA9m9z+oK15AEjWMsr2cvQbZbcQXQJiwDsHvZvs1hNHt08FiTBU5vNR8qWFAKwe9i/zWI1eQA4zCC0MdJsc6VK2dKNAOwddm+7WE8eaL7ZGm22vXKlfOlEAPaehu669eSB6kcTrmflxTbpNAcptSAQDgHYeVq66qkgD8AuwdNwxidnpReBNARJdXRTQx5dvPqZ5H7oVSfbWUMA9g07T4ukhjwAKOa9xFl+LS2VIuXMHwKwa9h3miRV5AFg1w1hMdg0QSxlFQTqIwB7hl2nTVJHHkjVXc9ApyEanTZjkPKaRwB2DHu2NQW9HiKpIw8og7RdiX/Uq1Y5lhYEYMdpnYaRSvKAYUj8Iy3uIeWshUAa4xy6LqklDyiBfiJeuCsiCKQNAdhtGuMcOs6pJg+Jf+hVKdtpQSDNcQ4d41STBxTpkfiHXp+ynQIEEOeA3aZdUk8eqADEP9I2Rp52w5HyN4dAlmw1E+SBasQsxLTMCWjO7OSqtCMA+0zDbNmwOGeGPKAwAlCSgRq26uU8kwjALtMeIPXjlSnygHLrh7PRn/RXlPydXgQQ34BdZk0yRx6csEcbRniCkeWrMGXNkESfYARgh7BH2GXWJHPkgQrCEO5VXGGSA5I1c02XPrA/2GEaU8/DIJ1J8oDiWMpNVVxmNQxTvXJOuxDA+1bUD1iG7S/DqpXWRhACaZf75Pe5HnGkaW2OZmor0+QBQLAC9ca10oVpxjjkmugIoKsCe7N95fPomlVfkXnygMr4BdjEFSpB1GoDkD2tQwD2peyM7S0PkgvyQEUiBoJfhCykBefBMNOmI+xKtXBz41EcCE5bJcUprxqFYQKRRLI4KMq1fgRgT1exXWV1VMWvr/d3rsgDSqs8EE7YkVR2zwTkOw4CsKMNbE9ZzONohEvuyMMDBKnCMpnOQ0O+m0EA9pO1lPMoOOQ6D9N7leX4NJHrRoFNzs0zAliPA9Pq8/7jk2vygAPAALCG5OUJouXlPLuE6B4GAQzFYsFiCbznLGBayzhgCJvXSSC1Fj6yv4TA5qu6lZ0IcZTwyG3Mw+8QiJQj8HVw/yC/1iGP4S8/IvK3hwDsAXZx1+Hh3I2oeBgEfee+2+IH5bpr+mjDui568scTNDMr/Rg/Pnn7u7+vgw7fPETr14qr+OteWh5+RPhvGMo9d6+lzRt5AF8k1wjADoQ4gk1AyCMYFw6iOnTX7RwZE8k1ArADkWAEhDyCcZG9goAg0AABIY8GAMlhQUAQCEZAyCMYF9krCAgCDRAQ8mgAkBwWBASBYASEPIJxibS3u0tgjARYm09Gfd18cE2bS5H+xzsuS/rVaK8G8wsuHXlpmm45xG+eErEeAdRXT7eMosStKCGPuAjK9YJAThGQ9nZOK17UFgTiIiDkERdBuV4QyCkCQh45rXhRWxCIi4CQR1wE5XpBIKcICHnktOJFbUEgLgJCHnERlOsFgZwiIOSR04oXtQWBuAgIecRFUK4XBHKKgJBHTite1BYE4iIg5BEXQbleEMgpAkIeOa14UVsQiIuAkEdcBOV6QSCnCAh55LTiRW1BIC4CQh5xEZTrBYGcIiDkkdOKF7UFgbgICHnERVCuFwRyioCQR04rXtQWBOIiIOQRF0G5XhDIKQJCHjmteFFbEIiLgJBHXATlekEgpwgIeeS04kVtQSAuAkIecRGU6wWBnCIg5JHTihe1BYG4CAh5xEVQrhcEcoqAkEdOK17UFgTiIiDkERdBuV4QyCkCQh45rXhRWxCIi4CQR1wE5XpBIKcICHnktOJFbUEgLgJCHnERlOsFgZwiIOSR04oXtQWBuAgIecRFUK4XBHKKQGdO9U6F2q5L5PI//EVF9Qf/jf+0/TgOKR3GAfX/yr6VY+oEtUtdX9rif0uHva/y7kYbjndCeYPI4f+U8Je323FKW+pftZ/PWjmIY9hU3yvHsKPg2+89Sr7tQ0DIw2CdgACKxZLzq23+G86Pbf6/attg0SI9aoVzyuRTuri8N9K9Gp3skYsiFRCLRzC8gX2l/Uw6hdJ2o/vJ8dYh4LDxJlPrrStjau4EIJeXi4oglkEKTBTLRf5bI4fUKJPCgupE01EoKELpAMEwsXR0FMotohSqZmWRhTxiVMsSE0X5A5JgshCxFwGQSCeTSicTifext7T2l0zII2IdLS4VaX5xiRaZOKTRFhE8y05HS6WLiaSnq5O6OmXsIGr1CHlEQGxqboEWFpcjXCGnpgWB7q4OGuztTktxrSin0K0V1SCFEATSh4C0PCLWmXRbIgJm8enSbYlXOUIeMfArB0sROJWAaQwkzVwqAdPW4izk0UI8Zai2hWA2cSsZqm0CtBiXCHnEAC/qpVlJEouqd5zzdULwb0uSWBxk418r5BEfw8Tu4GWdokUD4imlnq9mo2K/N1xcOuydUypS+Rj+xMnqa2Wj9MfKPvUV+h+klSspb0h6ugdJnr7/H6Dzvl4E1PvCAAAAAElFTkSuQmCC\"/><p style=\"margin-top:17.5px;font-size:15px;color:#697d91\">轻触屏幕，重新加载</p></div></body>"



-(void)showEmptyWebView{
    [self.jvWebView scrollEnable:NO];
    [super resizeJVWebview];
    NSString* jsString =[NSString stringWithFormat:@"<style>body{margin:0px;}</style><script type=text/javascript>var div=document.getElementById(\"body_wrapper\");div.innerHTML=\"轻触屏幕，重新加载\";div.style.width=\"%@\";div.style.height=%@+\"px\";div.style.fontSize=\"18px\";div.style.color=\"#999999\";div.style.textAlign=\"center\";div.style.lineHeight=div.style.height;div.addEventListener(\"click\",function(){window.location.href=\"ios://refresh_webview\";});</script>",@"100%",@"window.innerHeight"];
    NSString* htmlString = [NSString stringWithFormat:@"%@%@%@",HTML_START_FRAGMENT,jsString,HTML_END_FRAGMENT];
    [self.jvWebView loadHtmlString:htmlString];
}

-(void)showOnlineEmptyWebView{
    [self.jvWebView scrollEnable:NO];
    [super resizeJVWebview];
    NSString* jsString =[NSString stringWithFormat:@"<style>html,body{margin:0px; height:%@;}</style><script type=text/javascript>var div=document.getElementById(\"body_wrapper\");div.style.width=\"%@\";div.style.height=\"%@\";div.style.color=\"#999999\";div.addEventListener(\"click\",function(){window.location.href=\"ios://refresh_online_webview\";});</script>",@"100%",@"100%",@"100%"];
    NSString* htmlString = [NSString stringWithFormat:@"%@%@%@",HTML_RETRY_START_FRAGMENT,jsString,HTML_END_FRAGMENT];
    [self.jvWebView loadHtmlString:htmlString];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.model.naviBarStyle isEqualToString:@"0"]){
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self viewOnAppearCallJS];
    //注册监听
//    [LuURLInterceptCenter registerLuURLProtocols:URLProtocolRegisterTypeJavaScript|URLProtocolRegisterTypeCSS|URLProtocolRegisterTypeFont|URLProtocolRegisterTypeLSQImage];
}

- (void)viewOnAppearCallJS{
    [self.jvWebView callJS:@"window.onViewAppear&&window.onViewAppear()"];
    if (self.pageTag.length > 0 && self.pageParams.count > 0) {
        [self.jvWebView callJS:[NSString stringWithFormat:@"window.onBackTargetPage&&window.onBackTargetPage(%@)",[self.pageParams objectForKey:@"h5params"]?:@""]];
        self.pageParams = nil;
    }
}

- (void)viewOnDisappearCallJS{
    [self.jvWebView callJS:@"window.onViewDisappear&&window.onViewDisappear()"];
}

//override--自定义navigationBar
-(void)initNavigationBar{
    [super initNavigationBar];
    //Lu 自己的头部字体大小和颜色
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,
                              [UIFont systemFontOfSize:18],NSFontAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = attributes;
}

#pragma mark - Common Action
-(void)setNavigationStyle:(NSInteger) stype{
    // 0:白色导航栏   1:蓝色导航栏
    if(self.h5SettingHeader)//标识标识如果h5接管了头部，就不需要native来触发了，全部交给JS来触发
        return;
    
    UIImage *defaultBackgroundImage = [JVUtility imageWithColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:defaultBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:defaultBackgroundImage];
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys: COLOR_HEX(@"13334d"),NSForegroundColorAttributeName,
                              [UIFont systemFontOfSize:18],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    
    if (stype == 1) {
        SaberBackButton *backBtn = (SaberBackButton *)self.navigationItem.leftBarButtonItem.customView;
        if ([backBtn isKindOfClass:[SaberBackButton class]]) {
            [backBtn setTitleColor:COLOR_HEX(@"5064eb") forState:UIControlStateNormal];
            [backBtn setTitleColor:COLOR_HEX(@"5064eb") forState:UIControlStateSelected];
            [backBtn setTitleColor:COLOR_HEX(@"5064eb") forState:UIControlStateHighlighted];
        }
    }else{
        SaberBackButton *backBtn = (SaberBackButton *)self.navigationItem.leftBarButtonItem.customView;
        if ([backBtn isKindOfClass:[SaberBackButton class]]) {
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark --- DotButton Post Initialize

- (void)doJvActionTaskParserImp:(NSDictionary*)param{   //此处super验证下
    JVActionModel* actionModel = [[JVActionModel alloc]initWithDic:param];
    [super doJVAction:actionModel];
}

- (void)popCurrentViewTaskParserImp:(NSDictionary*)param {
    if ([self.model.fakePresent isEqualToString:@"1"]) {
        [self coreAnimationWithPopBlock:^id{
            return [self.navigationController popViewControllerAnimated:NO];
        }];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 覆写基类task
-(void)taskPushView:(NSDictionary*)param{
    
    NSString *webUrl = [param objectForKey:@"webUrl"];
    LufaxRootViewController * vc = [[LufaxRootViewController alloc] initWithDictionary:param];
    vc.hidesBottomBarWhenPushed = YES;
    vc.popCallbackTarget = self;
    
    if ([vc.model.fakePresent isEqualToString:@"1"]) {
        [self coreAnimationWithPushBlock:^{
            [self.navigationController pushViewController:vc animated:NO];
        }];
    }
    else {
        [self.navigationController pushViewController:vc animated:YES];
        vc.tabBarController.tabBar.hidden = YES;
    }
}

- (void)backButtonTaskParserImp:(NSDictionary*)param {
    NSString * callBack = [param objectForKey:@"callback"];
    if (callBack && callBack.length>0)
        backButtonCB = callBack;
    else
        backButtonCB = nil;
}

- (BOOL)h5OnlineTakeOverLoading
{
    if ([self.model.hideNativeLoading isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

-(NSString*)importGlobalJS{
    NSString *url = @"";
    NSString* jsScript = [NSString stringWithFormat:@"window.M_RES_URL=\"%@\";",url];
    NSDictionary* deviceInfo = @{};
    NSDictionary* appInfo = @{
                              @"OS_PLATFORM":@"iOS",
                              @"OS_VERSION":[deviceInfo objectForKey:@"osVersion"],
                              @"APP_VERSION":@"",
                              @"DEVICE_BRAND":@"Apple",
                              @"DEVICE_MODEL":[deviceInfo objectForKey:@"desc"],
                              @"NETWORK_TYPE":@"",
                              @"APP_REGION":@"LuSH",
                              @"isAppleContestOn":@"0",// 审核开关
                              };
    jsScript = [jsScript stringByAppendingString:[NSString stringWithFormat:@"window.luAppInfo=%@;",JSON_STRING_FROM_DIC(appInfo)]];
    
    //APP-8467 指纹推广需求,h5获取业务对接指纹推广开关
    NSDictionary *v2SwitchInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"localTotalV2SwitchInfo"];
    if (v2SwitchInfo) {
        jsScript = [jsScript stringByAppendingString:[NSString stringWithFormat:@"window.v2Switch=%@;",JSON_STRING_FROM_DIC(v2SwitchInfo)]];
    }

    NSDictionary* h5Performance = @{
                                    @"sessionId":@"",
                                    @"pageId":@"",
                                    @"createTime":@"",
                                    @"pageStartTime":@""
                                    };
    jsScript = [jsScript stringByAppendingString:[NSString stringWithFormat:@"window.h5Performance=%@;",JSON_STRING_FROM_DIC(h5Performance)]];
    
    jsScript = [jsScript stringByAppendingString:@"window.numberKeyboardCallback = function (str) {var ele = document.activeElement; if (ele && ele.nodeName === 'INPUT' && str === '.' && ele.value.indexOf('.') === -1) { var value = ele.value;console.log(value); var index = ele.selectionStart; console.log(index);ele.value = value.slice(0, index) + '.' + value.slice(index); ele.selectionStart = index + 1; ele.selectionEnd = index + 1; } };"];
    return jsScript;
}


- (void)jvWebViewDidStartLoad:(id)webView {
    [super jvWebViewDidStartLoad:webView];
    //开始加载之前先把旧数据清理掉
//    [[LuOfflineInterceptTraceManager defaultManager] clearAllInfo];
}

- (void)jvWebViewDidFinishLoad:(id)webView{
    [super jvWebViewDidFinishLoad:webView];
}

- (BOOL)handleOfflineInterceptWithLoadFail:(BOOL)loadFail
{
    BOOL isIntercepted = NO; //是否被拦截
    return isIntercepted;
}


-(void)callLocalJsModel:(JVLocalModel*)__model val:(NSString*)val {
    NSString* callJS = [NSString stringWithFormat:@"%@(%@,%@)",__model.callback,val,[self getJSParameter]];
    [self __callJSIfSuccess:callJS];
}


//读取失败
- (void)jvWebView:(id)webView didFailLoadWithError:(NSError *)error{
    
    
    if(![self.model.webViewLoadType isEqualToString:@"1"]){
        [self showEmptyWebView];
    }
    
    if ([self.model.webViewLoadType isEqualToString:@"1"] && error.code != -999) {
        [self showOnlineEmptyWebView];
    }
    BOOL isIntercepted = [self handleOfflineInterceptWithLoadFail:YES];
}

-(void)goToTop:(id)sender{
    [self.refreshView scrollToTop];
}

#pragma mark - alert_view
- (void)showAlertView:(NSDictionary*)dictionary
{
    NSString* alertContent = [dictionary objectForKey:@"alertContent"];
    NSString* tag = [[alertContent componentsSeparatedByString:@"|"]objectAtIndex:0];
//    if([tag isEqualToString:@"0"]||[tag isEqualToString:@"1"]||[tag isEqualToString:@"3"]) {//3为带自定义颜色的alert view
//        [gAppRootVC transferFmkAlertView:nil];
//    }else{
//        UIViewController *viewCtrl = [Utility luFetchCurrentTopViewController:self];
//        [gAppRootVC transferFmkAlertView:viewCtrl.view];
//    }
//    [gAppRootVC.fmkAlertView showAppAlertView:alertContent withCallbackDelegate:self];
}




#pragma mark - fakePresent
-(void)archerBtnClicked:(id)sender{
    if (backButtonCB && backButtonCB.length>0) {
        NSString * jsParam = [NSString stringWithFormat:@"%@()",backButtonCB];
        [self.jvWebView callJS:jsParam];
        return;
    }
    
    if ([self.model.fakePresent isEqualToString:@"1"]) {
        [self coreAnimationWithPopBlock:^id{
            return [self.navigationController popViewControllerAnimated:NO];
        }];
    }
    else if(self.isThirdPage) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else {
        [super archerBtnClicked:sender];
    }
    
    if ([sender isKindOfClass:[SaberBackButton class]]) {

    }
}

- (void)popViewControllerByBackBtnBackTag:(NSString *)tag backParams:(NSDictionary *)backParams animated:(BOOL)animated
{
//    UIViewController *backVC = [LFGlobalMethod popAppointVCByPageTag:tag param:backParams navigationC:self.navigationController];
//    if (backVC) {
//        [self.navigationController popToViewController:backVC animated:animated];
//    } else {
//        [self.navigationController popToRootViewControllerAnimated:animated];
//    }
}

- (id)coreAnimationWithPopBlock:(id (^)(void))popBlock {
    // Take screenshot and scale
    UIGraphicsBeginImageContextWithOptions(self.navigationController.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [self.navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *lastImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * lastView = [[UIImageView alloc] initWithImage:lastImage];
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    lastView.contentMode = UIViewContentModeBottom;
    lastView.frame = CGRectMake(0, statusBarHeight, CGRectGetWidth(lastView.frame), CGRectGetHeight(lastView.frame)-statusBarHeight);
    lastView.clipsToBounds = YES;
    [self.navigationController.view.superview addSubview:lastView];
    
    id result = popBlock();
    
    [UIView animateWithDuration:0.3 animations:^{
        lastView.frame = CGRectMake(0, CGRectGetHeight(lastView.frame)+statusBarHeight, CGRectGetWidth(lastView.frame), CGRectGetHeight(lastView.frame));
    } completion:^(BOOL finished) {
        if(finished){
            [lastView removeFromSuperview];
        }
    }];
    return result;
}

- (void)coreAnimationWithPushBlock:(void (^)(void))pushBlock {
    // Take screenshot and scale
    UIGraphicsBeginImageContextWithOptions(self.navigationController.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [self.navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *lastImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * lastView = [[UIImageView alloc] initWithImage:lastImage];
    [self.navigationController.view.superview addSubview:lastView];
    
    CGRect sf = self.navigationController.view.frame;
    CGRect vf = self.navigationController.view.bounds;
    // Present view animated
    self.navigationController.view.frame = CGRectMake(0, vf.size.height, vf.size.width, vf.size.height);
    
    pushBlock();
    
    [self.navigationController.view.superview bringSubviewToFront:self.navigationController.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.frame = sf;
    } completion:^(BOOL finished) {
        if(finished){
            [lastView removeFromSuperview];
        }
    }];
}

/* 整个Bar的控制
 {
 isHide:"0",
 color:"CCCCCC",
 title:"自定义Title",
 titleColor:"FF0000"
 }
 */
-(void)naviBarChanged:(NSDictionary*)changeDic{
    NSDictionary* naviDic = [changeDic objectForKey:@"RZDBChangeNew"];
    //是否隐藏
    BOOL isHide = [[naviDic objectForKey:@"isHide"] isEqualToString:@"1"]?YES:NO;
    [self.navigationController setNavigationBarHidden:isHide];
    //背景颜色
    NSString* color = [naviDic objectForKey:@"color"];
    if (color)[self.navigationController.navigationBar setBackgroundImage:[JVUtility imageWithColor:COLOR_HEX(color)] forBarMetrics:UIBarMetricsDefault];
    [self handleNavigatorBottomLineWithNaviDic:naviDic];
    
    self.navigationItem.titleView=nil;
    self.model.centerNaviItem=nil;
    //Title
    NSString* title = [naviDic objectForKey:@"title"];
    if(title) {
        // 为了解决Bug：iOS 10的系统，当title过长的时候，title会右对齐，现在当title过长，直接截断
        // 做了iOS 10的demo，其实是正常的，应该是我们App的问题，但是没找到原因。。。
        NSMutableString *mString = [[NSMutableString alloc] initWithString:title];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:18];
        label.text = [mString copy];
        [label sizeToFit];
        
        while (CGRectGetWidth(label.frame) > 250) {
            [mString deleteCharactersInRange:NSMakeRange(mString.length-1, 1)];
            label.text = [mString copy];
            [label sizeToFit];
        }
        
        if ([title isEqualToString:[mString copy]]) {
            self.title=title;
        } else {
            self.title=[NSString stringWithFormat:@"%@...", mString];
        }
    }
    //字体颜色
    NSString* titleColor = [naviDic objectForKey:@"titleColor"]?:@"556677";
    UIColor* fontColor=COLOR_HEX(titleColor);
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:fontColor,NSForegroundColorAttributeName,[UIFont systemFontOfSize:18],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    [self resizeJVWebview];
}

//navibar底部线是否隐藏
- (void)handleNavigatorBottomLineWithNaviDic:(NSDictionary *)naviDic
{
    UIImage *defaultBackgroundImage = [JVUtility imageWithColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setShadowImage:defaultBackgroundImage];
}

#pragma mark ----------------SPA控制NAVIGATION_BAR左边按钮---------------------------
/* 返回按钮的控制，只有显示和不显示，显示时候设置color
 {
 isHide:"0",
 color:"5064eb", //hide为0的情况下，最好设置对应button颜色,否则默认白色为0
 hook:"callback"
 }
 */

-(void)leftViewChanged:(NSDictionary*)changeDic{
    NSMutableDictionary* naviDic = [[changeDic objectForKey:@"RZDBChangeNew"] mutableCopy];
    //是否隐藏
    BOOL isHide = [[naviDic objectForKey:@"isHide"] isEqualToString:@"1"]?YES:NO;
    if (isHide) {
        self.navigationItem.leftBarButtonItem=nil;
        [self.navigationItem setHidesBackButton:YES];
    }else{
        NSString* callbackId = [naviDic objectForKey:@"callbackId"];
        NSString *style = [naviDic objectForKey:@"style"];
        SaberBackButton* backBtn = [[SaberBackButton alloc]initWithDictionary:[self containStyleParamBackBtnDicWithStyle:style]];

        if(callbackId && callbackId.length > 0){
            backBtn.model.jsCallBack=callbackId;
            backBtn.model.jvActionModel.actionId=@"-1";
            backBtn.model.userInfo=[naviDic objectForKey:@"taskInfo"];
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        NSString* color = [naviDic objectForKey:@"color"]?:@"FF";
        if(color)[backBtn setTitleColor:COLOR_HEX(color) forState:UIControlStateNormal];
        [backBtn addArcherTarget:self];
        
        // 5.0.5新增：除了原来的X（关闭）和<（返回），如果直接下发leftText，那么不使用iconfont
        NSString *leftText = naviDic[@"leftText"];
        if (leftText && leftText.length > 0) {
            [backBtn setTitle:leftText forState:UIControlStateNormal];
            backBtn.titleLabel.font = JVFONT(14);
            backBtn.imageEdgeInsets = UIEdgeInsetsZero;
            backBtn.titleEdgeInsets = UIEdgeInsetsZero;
        }
    }
}

- (NSDictionary *)containStyleParamBackBtnDicWithStyle:(NSString *)style
{
    if (![@"1" isEqualToString:style]) {
        return self.model.backBtnDic;
    }else {
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        if (self.model.backBtnDic.allKeys.count>0) {
            [newDic addEntriesFromDictionary:self.model.backBtnDic];
        }
        [newDic setObject:style forKey:@"style"];
        return newDic;
    }
}

/*回调时候要回传task sessionId hook*/
-(NSString*)__formatCommonHook:(NSDictionary*)hookDic{
    return JSON_STRING_FROM_DIC(hookDic);
}

#pragma mark ----------------SPA控制NAVIGATION_BAR右边按钮---------------------------
/* 返回按钮的控制，只有显示和不显示，显示时候设置color
 {
 isHide:"0",
 color:"5064eb", //hide为0的情况下，最好设置对应button颜色,否则默认5064eb为0,
 "title":"",
 "hook":"" // jsCallback,right
 }
 */

-(void)centerViewChanged:(NSDictionary*)changeDic{
    NSMutableDictionary* naviDic = [[changeDic objectForKey:@"RZDBChangeNew"] mutableCopy];
    if(naviDic){
        NSString* type = [naviDic objectForKey:@"type"]?:@"0";
        switch (type.integerValue) {
            case 0:
                [self setSingleTitle:naviDic];
                break;
            case 1:
//                [self setCenterTab:naviDic];
                break;
            case 2:
                [self setSubTitle:naviDic];
                break;
            case 3:
//                [self setSearchBarTitleView:naviDic];
                break;
            default:
                break;
        }
        
        [self handleNavigatorBottomLineWithNaviDic:naviDic];
    }
    
}

-(void)setSubTitle:(NSDictionary*)naviDic{
    [self setSingleTitle:naviDic];
    NSString* title = [naviDic objectForKey:@"subTitle"]?:@"";
    NSString* color = [naviDic objectForKey:@"subTitleColor"]?:@"FF";
    NSString* size = [naviDic objectForKey:@"subFontSize"]?:@"12";
    UIView* __centerView = self.navigationItem.titleView;
    UIView* titleWrapperView=[[UIView alloc]initWithFrame:__centerView.frame];
    self.navigationItem.titleView=titleWrapperView;
    CGRect frame = __centerView.frame;
    frame.origin.y -= 10;
    __centerView.frame = frame;
    
    UILabel* label = [UILabel new];
    [label setFont:JVFONT(size.integerValue)];
    [label setText:title];
    [label setTextColor:COLOR_HEX(color)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label sizeToFit];
    label.center=titleWrapperView.center;
    frame = label.frame;
    frame.origin.y =  CGRectGetMaxY(__centerView.frame)-10;
    label.frame = frame;
    [titleWrapperView addSubview:__centerView];
    [titleWrapperView addSubview:label];
    
    
}

-(void)setSingleTitle:(NSDictionary*)naviDic{
    NSString* title = [naviDic objectForKey:@"title"];
    if ([title isEqualToString:self.title]) {
        return;
    }
    
    NSString* color = [naviDic objectForKey:@"color"]?:@"FF";
    NSString* size = [naviDic objectForKey:@"fontSize"]?:@"18";
    NSString* iconText = [naviDic objectForKey:@"iconText"];
    NSString* iconColor = [naviDic objectForKey:@"iconColor"]?:color;
    NSString* iconAlign = [naviDic objectForKey:@"iconAlign"]?:@"0";
    NSString* callbackId = [naviDic objectForKey:@"callbackId"];
    NSInteger offsetIcon = 5; // 700 版本将左边距改成 5pt
    NSInteger titleViewHeight = 44;
    UILabel* label = [UILabel new];
    [label setFont:JVFONT(size.integerValue)];
    [label setText:title];
    [label setTextColor:COLOR_HEX(color)];
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.size.height=titleViewHeight;
    UIView* titleWrapperView;
    if(callbackId == nil || callbackId.length == 0){
        titleWrapperView = [[UIView alloc] init];
    }else{
        titleWrapperView = [[ArcherButton alloc] initWithDictionary:@{@"title":@"",@"jsCallBack":callbackId,@"userInfo":[naviDic objectForKey:@"taskInfo"]}];
        [(ArcherButton*)titleWrapperView addArcherTarget:self];
    }
    UILabel* iconLabel;
    if(iconText){
        iconLabel = [UILabel new];

        // 5.0.3新增，使用fontStyle进行navigationBar上titleView iconFont的扩展
        NSString *fontStyle = [naviDic objectForKey:@"fontStyle"] ?: @"1";
        if ([fontStyle isEqualToString:@"2"]) {
            [iconLabel  setFont:JV_ICON_FONT(@"iconfont", 18.0f)];
        } else if ([fontStyle isEqualToString:@"3"]) {
            [iconLabel  setFont:JV_ICON_FONT(@"iconfontv2", 18.0f)];
        } else {
            [iconLabel  setFont:JV_ICON_FONT(@"iconfont-framework", 18.0f)];
        }
        
        [iconLabel setText:[JVUtility iconFontFromHexStr:iconText]];
        [iconLabel setTextColor:COLOR_HEX(iconColor)];
        [iconLabel sizeToFit];
        CGRect frame = label.frame;
        frame.size.height=titleViewHeight;
        frame.size.width = iconLabel.bounds.size.width + 2; // 700 版本 解决疑问号显示不完整的问题
        label.frame = frame;
        UIView* titleWrapperView;
    }
    
    if(iconLabel){
        
        CGFloat titleViewWidth = label.frame.size.width+iconLabel.frame.size.width+offsetIcon;
        titleWrapperView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - titleViewWidth) / 2.0, 0, titleViewWidth, titleViewHeight);
        
        if([iconAlign isEqualToString:@"0"]){
            [titleWrapperView addSubview:label];
            [titleWrapperView addSubview:iconLabel];
            CGRect frame = iconLabel.frame;
            frame.origin.x = label.frame.size.width+offsetIcon;
            iconLabel.frame = frame;
        }else{
            [titleWrapperView addSubview:label];
            [titleWrapperView addSubview:iconLabel];
            CGRect frame = label.frame;
            frame.origin.x = label.frame.size.width+offsetIcon;
            label.frame = frame;
        }
        self.navigationItem.titleView=titleWrapperView;
    }else{
        self.navigationItem.titleView=label;
    }
}


//archerButtonCallback hook for v2 bridge
-(void)btnClickCallJS:(ArcherButton*)button{
    NSString* version = [button.model.userInfo objectForKey:@"version"]?:@"1";
    if(button.model.jsCallBack){
        if([version isEqualToString:@"2"]){
            NSMutableDictionary* __taskDic = [button.model.userInfo mutableCopy];
            [__taskDic setObject:button.model.jsCallBack forKey:@"callbackId"];
            [self.jvWebView callJSV2:__taskDic];
        }else{
            [super btnClickCallJS:button];
        }
        
    }
}


-(void)localStrogeValue:(NSDictionary *)param
{
    NSString *callBack = [param objectForKey:@"callback"];
    NSString *key = [param objectForKey:@"key"];
    NSString *value = [param objectForKey:@"value"];

    if ([key isKindOfClass:[NSString class]] && key.length) {
        if ([param.allKeys containsObject:@"value"]) {
            //write
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            //read
            id val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if (!val) {
                val = @"-1";
            }
            
            NSString* version = [param objectForKey:@"version"]?:@"1";
            if([version isEqualToString:@"2"]){
                NSMutableDictionary* __mutDic = [param mutableCopy];
                [__mutDic setObject:val forKey:@"result"];
                [__mutDic setObject:callBack forKey:@"callbackId"];
                [self.jvWebView callJSV2:__mutDic];
            }else{
                NSString *jsCallBack = [NSString stringWithFormat:@"%@('%@')",callBack,val];
                [self.jvWebView callJS:jsCallBack];
            }
        }
    }
}




#pragma mark -

- (NSString *)fetchCallbackId:(NSDictionary *)params
{
    NSString *callbackId = params[@"callbackId"];
    if (callbackId == nil || callbackId.length == 0) {
        callbackId  = params[@"callback"];
    }
    
    return callbackId;
}

@end
