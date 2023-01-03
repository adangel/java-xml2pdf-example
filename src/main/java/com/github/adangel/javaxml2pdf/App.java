/*
   Copyright 2023 Andreas Dangel

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */
package com.github.adangel.javaxml2pdf;

import java.io.BufferedOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.FopFactoryBuilder;
import org.apache.fop.apps.MimeConstants;
import org.apache.fop.configuration.Configuration;
import org.apache.fop.configuration.DefaultConfigurationBuilder;

public class App {
    public static void main(String[] args) {
        try {
            System.out.println("Java XML2PDF Example");
            System.out.println("--------------------\n");

            if (args.length != 1) {
                System.out.println("Requires exactly one argument to the XML file to be converted into PDF");
                System.exit(1);
            }
            Path inputXml = Path.of(args[0]);
            if (!Files.isRegularFile(inputXml)) {
                System.out.printf("The file %s does not exist!%n", inputXml);
                System.exit(1);
            }

            String filename = inputXml.toString();
            if (filename.lastIndexOf('.') != -1) {
                filename = filename.substring(0, filename.lastIndexOf('.'));
            }
            filename = filename + ".pdf";
            Path outputPdf = Path.of(filename);

            System.out.printf("Input XML File: %s%n", inputXml);
            System.out.printf("Output PDF File: %s%n", outputPdf);
            System.out.println();
            System.out.println("Transforming...");

            DefaultConfigurationBuilder cfgBuilder = new DefaultConfigurationBuilder();
            Configuration cfg = cfgBuilder.build(App.class.getResourceAsStream("/fop.xconf"));
            URL xslResource = App.class.getResource("/doc2fo.xsl");
            String baseUri = xslResource.toURI().toString();
            baseUri = baseUri.substring(0, baseUri.length() - "doc2fo.xsl".length());
            final FopFactory fopFactory = new FopFactoryBuilder(URI.create(baseUri))
                    .setConfiguration(cfg)
                    .build();
            FOUserAgent foUserAgent = fopFactory.newFOUserAgent();
            foUserAgent.setPdfUAEnabled(true);
            foUserAgent.setAccessibility(true);
            foUserAgent.getRendererOptions().put("pdf-a-mode", "PDF/A-1a");

            try (OutputStream out = new BufferedOutputStream(Files.newOutputStream(outputPdf));
                 InputStream xsl = xslResource.openStream()) {
                // Construct fop with desired output format
                Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, foUserAgent, out);

                // Setup XSLT
                TransformerFactory factory = TransformerFactory.newInstance();
                Transformer transformer = factory.newTransformer(new StreamSource(xsl));

                // Setup input for XSLT transformation
                Source src = new StreamSource(inputXml.toFile());

                // Resulting SAX events (the generated FO) must be piped through to FOP
                Result res = new SAXResult(fop.getDefaultHandler());

                // Start XSLT transformation and FOP processing
                transformer.transform(src, res);
            }

            System.out.println("Success!");
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }
    }
}
