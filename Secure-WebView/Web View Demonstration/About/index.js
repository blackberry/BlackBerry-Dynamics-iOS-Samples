/* Copyright (c) 2016 BlackBerry Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
function child(parent, tag, attrArray=null, text=null, insert=false) {
    const textNode = (
        text === null ? null : document.createTextNode(text));
    const element = (
        tag === null ? null : document.createElement(tag));

    if (element) {
        if (textNode) {
            element.appendChild(textNode);
            element.normalize();
        }
        if (insert) {
            parent.insertBefore(element, parent.firstChild);
        }
        else {
            parent.appendChild(element);
        }
        if (attrArray !== null) {
            for(const[key, value] of attrArray) {
                element.setAttribute(key, value);
            }
        }
        return element;
    }
    parent.appendChild(textNode);
    parent.normalize();
    return textNode;
}

function main(settings) {
    return child(document.body, 'pre', null, settings) ? true : false;
}
