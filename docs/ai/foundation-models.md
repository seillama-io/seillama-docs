# Foundation models

Download this section as a [mindmap](https://github.com/seillama-io/seillama-docs/releases/download/v0.1.36/foundation-models.pdf)!

## Overview

- Pre-trained on **unlabeled datasets**
- Leverage **self-supervised learning**
- Learn **generalizable & adaptable data representations**
- Can be effectively used in **multiple downstream tasks** (e.g., text generation, machine translation, classification for languages)
- **Note**: while transformer architecture is most prevalent in foundation models, definition not restricted by model architecture

## Data Modalities

- Natural Language
- Speech
- Business Data
- IT Data
- Sensor Data
- Chemistry & Materials
- Geospatial
- Programming Languages (Code)
- Images
- Dialog

## Architectures

### Encoder-only

- Best cost performance trade-off for **non generative** use cases
- Most classical NLP tasks: classification, entity and relation extraction, extractive summarization, extractive question answer, etc.
- Require task-specific **labeled data for fine tuning**. Examples: BERT/RoBERTa models.

### Encoder-Decoder

- Support **both generative and non-generative** use cases
- Best cost performance trade-off for generative use cases when input is large but generated output is small.
- **Can be prompt-engineered once we hit a size of ~10B** but below that can be **fine tuned using labeled data**. Examples: Google T5 models, UL2 models.

### Decoder-only

- Designed explicitly for **generative AI** use cases
- summarization, generative question answer, translation, copywriting
- Architectures used in GPT-3, ChatGPT, etc.

## Training and Tuning (⬇️ value)

### Base model 

- Pre-trained on 10s of TBs of unlabeled Internet data
- **Examples**: Watson Studio base LLM models, Google T5, etc.

### Custom pre-trained model

- Pre-trained on 10s of GB of domain/industry specific data
- **Examples**: IBM-NASA collaboration models, Watson Code Assistant models

### Fine-tuned model

- Fine-tuned on a class of tasks
- **Examples**: Watson NLP OOTB Entity, Sentiment models, Google FLAN T5, ***watsonx sandstone.instruct***

### Human-in-the-loop refined model

- ChatGPT, ***watsonx sandstone.chat***

## Adaptation to multiple tasks (⬇️ complexity/skills, ⬆️ model size)

### Prompt engineering

- **Training**: None
- **Inference**: Engineered Prompt + Input Text ➡️ output
- Designing and constructing effective prompts to obtain desired outputs
- Recommended way to start
- Advantages ➕
  - Quick experimentation for various tasks
  - Little to no training data
- Disadvantages ➖
  - Success depends on choice of prompt and model size
  - Mostly a trial-and-error process
  - Number of examples limited by prompt input size limitations
  - Lower accuracy compared to fine-tuning
  - Longer prompts may give better accuracy but cost more

### Prompt-tuning

- **Training**: Pre-trained model + Labeled Data ➡️ Prompt-Tuning Algorithm ➡️ Tuned Soft Prompt
- **Inference**: Tuned Soft Prompt + Input Text ➡️ Pre-trained model ➡️ output
- Relatively new technique
- Training data format is the same as for fine tuning
- Pre-trained models: LLMs with decoders
- Advantages ➕
  - Faster training as only few parameters are learnt
  - Model accuracy comparable to fine tuning in some cases
  - The Pre-trained model is reused for inference in multiple tasks
  - Middle ground between fine-tuning and prompt engineering
  - Fewer parameters compared to fine tuning

### Fine-tuning

- **Training**: Pre-trained model + Labeled Data ➡️ Fine-Tuning Algorithm ➡️ Fined-Tuned model
- **Inference**: Input Text ➡️ Fined-Tuned model ➡️ output
- 📈 SotA accuracy with small models and many popular NLP tasks (classification, extraction)
- Requires data science expertise 
- Requires **separate instance of the model for each task** (can be expensive)
- Difficult as model size increases (e.g., overfitting issues) i.e. typically less than 1B parameters

## Enterprise considerations

- Head-on comparison with ChatGPT is a trap
- A single solution does not fit all trust matters
- ROI determined by use case and inference cost
- Need to manage risks and limitations of today's LLMs
- Consider ability to run workloads as desired, train models, provide trusted models, backend integration, enterprise features, and other NFRs
