//
//  ContextMenuFrameTranslation.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/21/25.
//

import WebKit

extension MyWKWebView {
    func translationMenuItem() -> NSMenuItem {
        let item = NSMenuItem(title: "Translate Using Google", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Translate Using Google")
        item.submenu = menu

        let languages = [
            ("Acehnese", "ace"),
            ("Acholi", "ach"),
            ("Afrikaans", "af"),
            ("Albanian", "sq"),
            ("Alur", "alz"),
            ("Amharic", "am"),
            ("Arabic", "ar"),
            ("Armenian", "hy"),
            ("Assamese", "as"),
            ("Awadhi", "awa"),
            ("Aymara", "ay"),
            ("Azerbaijani", "az"),
            ("Balinese", "ban"),
            ("Bambara", "bm"),
            ("Bashkir", "ba"),
            ("Basque", "eu"),
            ("Batak Karo", "btx"),
            ("Batak Simalungun", "bts"),
            ("Batak Toba", "bbc"),
            ("Belarusian", "be"),
            ("Bemba", "bem"),
            ("Bengali", "bn"),
            ("Betawi", "bew"),
            ("Bhojpuri", "bho"),
            ("Bikol", "bik"),
            ("Bosnian", "bs"),
            ("Breton", "br"),
            ("Bulgarian", "bg"),
            ("Buryat", "bua"),
            ("Cantonese", "yue"),
            ("Catalan", "ca"),
            ("Cebuano", "ceb"),
            ("Chichewa (Nyanja)", "ny"),
            ("Chinese (Simplified)", "zh-CN"),
            ("Chinese (Traditional)", "zh-TW"),
            ("Chuvash", "cv"),
            ("Corsican", "co"),
            ("Crimean Tatar", "crh"),
            ("Croatian", "hr"),
            ("Czech", "cs"),
            ("Danish", "da"),
            ("Dinka", "din"),
            ("Divehi", "dv"),
            ("Dogri", "doi"),
            ("Dombe", "dov"),
            ("Dutch", "nl"),
            ("Dzongkha", "dz"),
            ("English", "en"),
            ("Esperanto", "eo"),
            ("Estonian", "et"),
            ("Ewe", "ee"),
            ("Fijian", "fj"),
            ("Filipino (Tagalog)", "fil"),
            ("Finnish", "fi"),
            ("French", "fr"),
            ("French (French)", "fr-FR"),
            ("French (Canadian)", "fr-CA"),
            ("Frisian", "fy"),
            ("Fulfulde", "ff"),
            ("Ga", "gaa"),
            ("Galician", "gl"),
            ("Ganda (Luganda)", "lg"),
            ("Georgian", "ka"),
            ("German", "de"),
            ("Greek", "el"),
            ("Guarani", "gn"),
            ("Gujarati", "gu"),
            ("Haitian Creole", "ht"),
            ("Hakha Chin", "cnh"),
            ("Hausa", "ha"),
            ("Hawaiian", "haw"),
            ("Hebrew", "he"),
            ("Hiligaynon", "hil"),
            ("Hindi", "hi"),
            ("Hmong", "hmn"),
            ("Hungarian", "hu"),
            ("Hunsrik", "hrx"),
            ("Icelandic", "is"),
            ("Igbo", "ig"),
            ("Iloko", "ilo"),
            ("Indonesian", "id"),
            ("Irish", "ga"),
            ("Italian", "it"),
            ("Japanese", "ja"),
            ("Javanese", "jv"),
            ("Kannada", "kn"),
            ("Kapampangan", "pam"),
            ("Kazakh", "kk"),
            ("Khmer", "km"),
            ("Kiga", "cgg"),
            ("Kinyarwanda", "rw"),
            ("Kituba", "ktu"),
            ("Konkani", "gom"),
            ("Korean", "ko"),
            ("Krio", "kri"),
            ("Kurdish (Kurmanji)", "ku"),
            ("Kurdish (Sorani)", "ckb"),
            ("Kyrgyz", "ky"),
            ("Lao", "lo"),
            ("Latgalian", "ltg"),
            ("Latin", "la"),
            ("Latvian", "lv"),
            ("Ligurian", "lij"),
            ("Limburgan", "li"),
            ("Lingala", "ln"),
            ("Lithuanian", "lt"),
            ("Lombard", "lmo"),
            ("Luo", "luo"),
            ("Luxembourgish", "lb"),
            ("Macedonian", "mk"),
            ("Maithili", "mai"),
            ("Makassar", "mak"),
            ("Malagasy", "mg"),
            ("Malay", "ms"),
            ("Malay (Jawi)", "ms-Arab"),
            ("Malayalam", "ml"),
            ("Maltese", "mt"),
            ("Maori", "mi"),
            ("Marathi", "mr"),
            ("Meadow Mari", "chm"),
            ("Meiteilon (Manipuri)", "mni-Mtei"),
            ("Minang", "min"),
            ("Mizo", "lus"),
            ("Mongolian", "mn"),
            ("Myanmar (Burmese)", "my"),
            ("Ndebele (South)", "nr"),
            ("Nepalbhasa (Newari)", "new"),
            ("Nepali", "ne"),
            ("Northern Sotho (Sepedi)", "nso"),
            ("Norwegian", "no"),
            ("Nuer", "nus"),
            ("Occitan", "oc"),
            ("Odia (Oriya)", "or"),
            ("Oromo", "om"),
            ("Pangasinan", "pag"),
            ("Papiamento", "pap"),
            ("Pashto", "ps"),
            ("Persian", "fa"),
            ("Polish", "pl"),
            ("Portuguese", "pt"),
            ("Portuguese (Portugal)", "pt-PT"),
            ("Portuguese (Brazil)", "pt-BR"),
            ("Punjabi", "pa"),
            ("Punjabi (Shahmukhi)", "pa-Arab"),
            ("Quechua", "qu"),
            ("Romani", "rom"),
            ("Romanian", "ro"),
            ("Rundi", "rn"),
            ("Russian", "ru"),
            ("Samoan", "sm"),
            ("Sango", "sg"),
            ("Sanskrit", "sa"),
            ("Scots Gaelic", "gd"),
            ("Serbian", "sr"),
            ("Sesotho", "st"),
            ("Seychellois Creole", "crs"),
            ("Shan", "shn"),
            ("Shona", "sn"),
            ("Sicilian", "scn"),
            ("Silesian", "szl"),
            ("Sindhi", "sd"),
            ("Sinhala (Sinhalese)", "si"),
            ("Slovak", "sk"),
            ("Slovenian", "sl"),
            ("Somali", "so"),
            ("Spanish", "es"),
            ("Sundanese", "su"),
            ("Swahili", "sw"),
            ("Swati", "ss"),
            ("Swedish", "sv"),
            ("Tajik", "tg"),
            ("Tamil", "ta"),
            ("Tatar", "tt"),
            ("Telugu", "te"),
            ("Tetum", "tet"),
            ("Thai", "th"),
            ("Tigrinya", "ti"),
            ("Tsonga", "ts"),
            ("Tswana", "tn"),
            ("Turkish", "tr"),
            ("Turkmen", "tk"),
            ("Twi (Akan)", "ak"),
            ("Ukrainian", "uk"),
            ("Urdu", "ur"),
            ("Uyghur", "ug"),
            ("Uzbek", "uz"),
            ("Vietnamese", "vi"),
            ("Welsh", "cy"),
            ("Xhosa", "xh"),
            ("Yiddish", "yi"),
            ("Yoruba", "yo"),
            ("Yucatec Maya", "yua"),
            ("Zulu", "zu")
        ].map { TranslatedLanguage(code: $0.1, name: $0.0) }

        let recentlyTranslatedLanguages = Preferences.recentlyTranslatedLanguages
        if !recentlyTranslatedLanguages.isEmpty {
            menu.addItem(NSMenuItem(title: "Recent", action: nil, keyEquivalent: ""))

            for language in recentlyTranslatedLanguages {
                let item = NSMenuItem(title: language.name, action: #selector(translate(_:)), keyEquivalent: "")
                item.representedObject = language
                menu.addItem(item)
            }
            menu.addItem(.separator())
        }

        for language in languages {
            let item = NSMenuItem(title: language.name, action: #selector(translate(_:)), keyEquivalent: "")
            item.representedObject = language
            menu.addItem(item)
        }

        return item
    }

    @objc func translate(_ sender: NSMenuItem) {
        guard let language = sender.representedObject as? TranslatedLanguage else { return }

        Preferences.recentlyTranslatedLanguages.removeAll { $0.code == language.code }
        Preferences.recentlyTranslatedLanguages.insert(language, at: 0)

        guard let getTextScript = JavaScript.getBundled("GetPageText") else { return }

        evaluateJavaScript(getTextScript) { result, error in
            guard let texts = result as? [String] else { return }

            let api = URL(string: "https://translate-pa.googleapis.com/v1/translateHtml")!

            var request = URLRequest(url: api)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json+protobuf",
                "X-goog-api-key": "AIzaSyATBXajvzQLTDHEQbcpq0Ihe0vWDHmO520",
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15 (Browser)",
                "Accept": "*/*",
                "Origin": "https://www.google.com",
            ]

            let requestBody = try? JSONSerialization.data(withJSONObject: [
                [texts, "auto", language.code],
                "te_lib"
            ])
            request.httpBody = requestBody

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    return print("❌ Translation failed: \(error)")
                }
                guard let data = data else { return print("❌ Translation failed: \(error?.localizedDescription ?? "Unknown error")") }
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [[Any]] else { return print("❌ Translation failed: Invalid JSON response") }
                guard let translatedTexts = json[0] as? [String] else { return print("❌ Translation failed: Invalid JSON structure: \(json)") }

                let transformedTexts = translatedTexts.map { CFXMLCreateStringByUnescapingEntities(nil, $0 as CFString, nil) as String }

                DispatchQueue.main.async {
                    let replaceScript = """
                        function replaceTexts(translations) {
                            const walker = document.createTreeWalker(
                                document.body,
                                NodeFilter.SHOW_TEXT, {
                                    acceptNode: function(node) {
                                        let parent = node.parentNode;
                                        while (parent) {
                                            const tag = parent.tagName ? parent.tagName.toLowerCase() : '';
                                            if (['script', 'style', 'meta', 'link', 'noscript'].includes(tag)) {
                                                return NodeFilter.FILTER_REJECT;
                                            }
                                            parent = parent.parentNode;
                                        }
                        
                                        const trimmedText = node.textContent.trim();
                                        if (!trimmedText ||
                                            trimmedText.length <= 1 ||
                                            trimmedText.startsWith('<') ||
                                            trimmedText.includes('{') ||
                                            trimmedText.includes('}') ||
                                            /^[\\s<>{}\\/]+$/.test(trimmedText)) {
                                            return NodeFilter.FILTER_REJECT;
                                        }
                        
                                        return NodeFilter.FILTER_ACCEPT;
                                    }
                                },
                                false
                            );
                        
                            let node;
                            let index = 0;
                            while (node = walker.nextNode()) {
                                if (index < translations.length) {
                                    // Preserve original spacing
                                    const originalSpaceBefore = node.textContent.match(/^\\s*/)[0];
                                    const originalSpaceAfter = node.textContent.match(/\\s*$/)[0];
                                    node.textContent = originalSpaceBefore + translations[index] + originalSpaceAfter;
                                    index++;
                                }
                            }
                        }
                        replaceTexts(\(transformedTexts));
                        """

                    self.evaluateJavaScript(replaceScript) { _, error in
                        if error == nil {
                            self.presentActionAlert?("Page Translated! Refresh To Revert", "translate")
                        }
                    }
                }
            }

            task.resume()
        }
    }
}
