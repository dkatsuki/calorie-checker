
const list = {}
table.querySelectorAll('tbody tr').forEach((tr) => {
  const row = Array.from(tr.querySelectorAll('td')).map(e => e)
  const ageKey = tr.querySelector('th').textContent
  list[ageKey] = row
})

const results = [['年齢', '参照体重(男)', '基礎代謝量(男)', '参照体重(女)', '基礎代謝量(女)']]

Object.keys(list).forEach((ageKey) => {
  const m = list[ageKey]['male'];
  const f = list[ageKey]['male'];
  results.push([ageKey, m['参照体重'], m['基礎代謝量'], f['参照体重'], f['基礎代謝量']])
})

console.log(results.map(row => row.join(',')).join("\n"))




const onLoad = () => {
  const nestedForm = document.querySelector('.nested_form')

  const setInputValueToNameKey = (event) => {
    const delimiter = '[';
    const wrapper = event.target.parentElement.parentElement;
    const target = wrapper.childNodes[1].querySelector('input');
    const splitedBaseName = target.name.split(delimiter);
    splitedBaseName[splitedBaseName.length - 1] = `${event.target.value}]`
    const newName = splitedBaseName.join(delimiter);
    target.name = newName;
  };

  const getKeyValueCombiElements = () => {
    return(nestedForm.querySelectorAll('.nested_form > div:not(.add_nested_record_button)'));
  }

  const setSetterFunctions = () => {
    getKeyValueCombiElements().forEach((parent) => {
      if (!parent.childNodes[0].onchange) {
        parent.childNodes[0].onchange = setInputValueToNameKey;
      }
    })
  }

  setSetterFunctions();

  const addNestedRecordButton = nestedForm.querySelector('.add_nested_record_button');
  addNestedRecordButton.classList.add(Date.now())

  const createRemoveButton = () => {
    const removeButton = document.createElement('div');
    removeButton.classList.add('remove_nested_record_button')
    removeButton.onclick = (event) => {
      event.target.parentElement.parentElement.parentElement.remove();
    }
    const pTag = document.createElement('p');
    pTag.textContent = '削除';
    removeButton.appendChild(pTag);
    return(removeButton);
  }

  addNestedRecordButton.onclick = () => {
    const baseElement = getKeyValueCombiElements()[0];
    const newElement = baseElement.cloneNode(true);
    const inputElements = newElement.querySelectorAll('input');
    newElement.id = `${Date.now()}`;
    inputElements.forEach((element) => {
      element.id = `${element.id}_${Date.now()}`;
      element.value = '';
    })

    newElement.childNodes[1].appendChild(createRemoveButton());
    newElement.dataset.order = nestedForm.childNodes.length;
    nestedForm.insertBefore(newElement, addNestedRecordButton);
    setSetterFunctions();
  }
}

window.addEventListener('turbo:load', onLoad)
window.addEventListener('turbo:submit-end', onLoad)
